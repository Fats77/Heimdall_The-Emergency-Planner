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

exports.createBuilding = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to create a building.",
    );
  }

  const { name, description, admin: adminInfo } = data;
  const uid = context.auth.uid;

  let inviteCode;
  let codeExists = true;
  
  while (codeExists) {
    inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const snapshot = await db.collection("buildings")
                             .where("inviteCode", "==", inviteCode)
                             .get();
    codeExists = !snapshot.empty;
  }

  try {
    // 4. Create the new building document
    const buildingRef = db.collection("buildings").doc();
    await buildingRef.set({
      name: name,
      description: description,
      inviteCode: inviteCode,
    });

    const memberRef = buildingRef.collection("members").doc(uid);
    await memberRef.set({
      displayName: adminInfo.displayName,
      email: adminInfo.email,
      role: "admin",
    });

    return { success: true, buildingId: buildingRef.id, inviteCode: inviteCode };
  } catch (error) {
    console.error("Error creating building:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while creating the building.",
    );
  }
});

exports.joinBuilding = functions.https.onCall(async (data, context) => {
  // 1. Check for authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to join a building.",
    );
  }

  const { inviteCode } = data;
  const uid = context.auth.uid;

  if (!inviteCode) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invite code is required.",
    );
  }

  try {
    const snapshot = await db.collection("buildings")
                             .where("inviteCode", "==", inviteCode)
                             .limit(1)
                             .get();

    if (snapshot.empty) {
      return { success: false, error: "Invalid invite code" };
    }

    const buildingDoc = snapshot.docs[0];
    const buildingId = buildingDoc.id;

    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User profile not found.");
    }
    const userData = userDoc.data();

    const memberRef = db.collection("buildings")
                        .doc(buildingId)
                        .collection("members")
                        .doc(uid);
    
    await memberRef.set({
      displayName: userData.displayName,
      email: userData.email,
      role: "member", // Default role
    });

    return { success: true, buildingId: buildingId };
  } catch (error) {
    console.error("Error joining building:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while joining the building.",
    );
  }
});