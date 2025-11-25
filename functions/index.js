/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * [HTTPS Callable] Triggers a new emergency alert.
 *
 * 1. Verifies the user is an admin.
 * 2. Creates a new 'event' document.
 * 3. Fetches all members of the building.
 * 4. Fetches their push notification (FCM) tokens.
 * 5. Sends a push notification to all members.
 */

// --- 1. [HTTPS Callable] Trigger Emergency Alert (Admin Only) ---
exports.triggerEmergencyAlert = functions.https.onCall(async (data, context) => {
  
  // --- Authentication ---
  if (!context.auth) {
      // IF THIS IS RETURNED, THE TOKEN IS BAD OR MISSING.
      throw new functions.https.HttpsError(
        "unauthenticated",
        "CONTEXT AUTH IS EMPTY (TOKEN NOT SENT OR INVALID)."
      );
    }

  const { buildingId, emergencyTypeId, emergencyTypeName } = data;
  const uid = context.auth.uid;

  // --- Verify Admin Role ---
  const memberDoc = await db
    .collection("buildings")
    .doc(buildingId)
    .collection("members")
    .doc(uid)
    .get();

  if (!memberDoc.exists || memberDoc.data().role !== "admin") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "You must be an admin of this building to trigger an alert."
    );
  }

  // --- Create the Event Document ---
  let eventRef;
  try {
    eventRef = await db
      .collection("buildings")
      .doc(buildingId)
      .collection("events")
      .add({
        emergencyTypeID: emergencyTypeId,
        eventName: `${emergencyTypeName} Alert`,
        startTime: admin.firestore.FieldValue.serverTimestamp(),
        endTime: null,
        status: "active",
        triggeredBy: uid,
        type: "alert",
      });
  } catch (error) {
    console.error("Error creating event doc:", error);
    throw new functions.https.HttpsError("internal", "Could not create event document.");
  }
  
  // --- Get Member FCM Tokens ---
  const membersSnapshot = await db
    .collection("buildings")
    .doc(buildingId)
    .collection("members")
    .get();
  
  const memberIds = membersSnapshot.docs.map((doc) => doc.id);
  
  const tokenPromises = memberIds.map((id) => db.collection("users").doc(id).get());
  const userDocs = await Promise.all(tokenPromises);
  
  const tokens = userDocs
    .map((doc) => doc.data()?.fcmToken) // Use optional chaining
    .filter((token) => token); 

  // --- Send Push Notifications ---
  if (tokens.length === 0) {
    return { status: "warning", message: "Event started, but no members to notify (no tokens found)." };
  }

  try {
    const payload = {
      notification: {
        title: "🚨 EMERGENCY ALERT 🚨",
        body: `An active ${emergencyTypeName} alert has been triggered for your building.`,
      },
      data: {
        type: "EMERGENCY_ALERT",
        buildingId: buildingId,
        eventId: eventRef.id,
        emergencyTypeID: emergencyTypeId,
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            'content-available': 1,
          },
        },
        headers: {
          'apn-priority': '10',
        },
      },
      tokens: tokens,
    };

    await messaging.sendMulticast(payload);
    return { status: "success", message: "Alert successfully triggered!" };

  } catch (error) {
    console.error("Error sending push notifications:", error);
    throw new functions.https.HttpsError("internal", "Event created, but failed to send notifications.");
  }
});


// --- 2. [HTTPS Callable] Export Attendance Report (Admin/Coordinator Only) ---
exports.exportAttendanceReport = functions.https.onCall(async (data, context) => {

  // --- 1. Authentication and Role Check ---
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const { buildingId, eventId } = data;
  const uid = context.auth.uid;

  // Check if user is Admin or Coordinator (Role 5 restriction)
  const memberDoc = await db.collection("buildings").doc(buildingId).collection("members").doc(uid).get();
  const userRole = memberDoc.data()?.role;

  if (userRole !== 'admin' && userRole !== 'coordinator') {
    throw new functions.https.HttpsError("permission-denied", "Access denied. Only Admins and Coordinators can export reports.");
  }

  // --- 2. Fetch Data ---
  const [eventDoc, attendanceSnapshot] = await Promise.all([
    db.collection("buildings").doc(buildingId).collection("events").doc(eventId).get(),
    db.collection("buildings").doc(buildingId).collection("events").doc(eventId).collection("attendance").get()
  ]);

  const eventData = eventDoc.data();
  if (!eventData) {
    throw new functions.https.HttpsError("not-found", "Event not found.");
  }

  // --- 3. Format CSV ---
  // Note: Added an extra header field for clearer reporting: Event Name/Date
  const headers = "Event Name,Status,Check-In Time,Manual Check-in By\n";

  const rows = attendanceSnapshot.docs.map(doc => {
    const data = doc.data();
    const status = data.status || 'inProgress';
    const checkInTime = data.safeTimestamp ? data.safeTimestamp.toDate().toISOString() : '';
    const checkedInBy = data.manuallyCheckedInBy || '';

    // Using display name from the attendance doc (data.name) and sanitize for CSV
    const name = (data.name || 'Unknown User').replace(/"/g, '""'); 

    return `"${name}","${status}","${checkInTime}","${checkedInBy}"`;
  }).join('\n');

  const csvContent = headers + rows;
  const fileName = `attendance_report_${eventData.eventName.replace(/[^a-z0-9]/gi, '_')}_${eventId}_${Date.now()}.csv`;
  const file = storage.bucket().file(`reports/${buildingId}/${fileName}`);

  // --- 4. Upload CSV to Storage ---
  await file.save(csvContent, {
    contentType: 'text/csv',
    metadata: {
      cacheControl: 'private, max-age=300' 
    }
  });

  // --- 5. Generate Signed URL (valid for 30 minutes) ---
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 1800 * 1000, // 30 minutes
    contentType: 'text/csv'
  });

  // --- 6. Return URL ---
  return { status: "success", downloadUrl: url };
});