//
//  EventService.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFunctions
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

class EventService {
    
    // FIX 1: Make the instance accessible via a calculated property (lazy singleton pattern)
    private static var _shared: EventService?
    
    static var shared: EventService {
        if _shared == nil {
            _shared = EventService()
        }
        return _shared!
    }
    
    // FIX 2: Make the initializer private to enforce the shared pattern
    private init() {
        // Initialization logic is moved here
        
        // --- CRITICAL CONFIGURATION ---
        // Get the initialized Firebase App instance
        guard let app = FirebaseApp.app() else {
            fatalError("Firebase App not initialized. Check AppDelegate setup.")
        }
        
        // Find your deployed region (e.g., "us-central1")
        let region = "us-central1" // REPLACE WITH YOUR FUNCTION'S REGION
        
        // Initialize Functions using the explicit app instance and region to ensure correct authentication context.
        self.functions = Functions.functions(app: app, region: region)
        // ------------------------------
    }
    
    // Note: The functions property is no longer static.
    private var functions: Functions! // Will be initialized in the private init()
    
    // MARK: - 1. TRIGGER ALERT (Admin Function)
    
    /// Triggers the server-side logic to start an event and notify members.
    /// Note: Push notification code is disabled/commented out on the server (index.js) due to persistent configuration errors.
    func triggerAlert(building: Building, emergency: EmergencyType) async -> (Bool, String) {
        
        guard let user = Auth.auth().currentUser else {
             return (false, "Local Auth Error: User is not logged in on device.")
        }
        
        // Step 1: Refresh token to maximize success of the security check
        do {
            let _ = try await user.getIDToken(forcingRefresh: true)
            print("Successfully refreshed ID Token. Proceeding with function call.")
        } catch {
            return (false, "Auth Token Refresh Failed: \(error.localizedDescription)")
        }
        
        guard let buildingID = building.id,
              let emergencyTypeID = emergency.id else {
            return (false, "Missing local IDs.")
        }
        
        let data: [String: Any] = [
            "buildingId": buildingID,
            "emergencyTypeId": emergencyTypeID,
            "emergencyTypeName": emergency.prettyType
        ]
        
        do {
            // Step 2: Call the triggerEmergencyAlert Cloud Function (handles event creation and member tracking start)
            _ = try await functions.httpsCallable("triggerEmergencyAlert").call(data)
            
            // Success means the event is active in Firestore and tracking has started.
            return (true, "Alert successfully triggered!")
            
        } catch {
            // Log the detailed error from the Firebase Function call
            print("Firebase Function Error: \(error.localizedDescription)")
            return (false, "Function Call Failed: \(error.localizedDescription). Check server logs for CONTEXT AUTH error.")
        }
    }
    
    // MARK: - 2. EXPORT ATTENDANCE (Coordinator Function)
    
    /// Calls the Cloud Function to generate a signed CSV report URL.
    /// Returns: (success, downloadURL_string)
    func exportAttendance(buildingID: String, eventID: String) async -> (Bool, String?) {
        
        guard let user = Auth.auth().currentUser else {
             return (false, nil)
        }
        
        // Refresh token before privileged action
        do {
            let _ = try await user.getIDToken(forcingRefresh: true)
        } catch {
            print("Export Auth Token Refresh Failed: \(error.localizedDescription)")
            return (false, nil)
        }
        
        let data: [String: Any] = [
            "buildingId": buildingID,
            "eventId": eventID
        ]
        
        do {
            // Call the exportAttendanceReport Cloud Function
            let result = try await functions.httpsCallable("exportAttendanceReport").call(data)
            
            // Parse the response, expecting the 'downloadUrl' key
            if let responseData = result.data as? [String: Any],
               let urlString = responseData["downloadUrl"] as? String {
                
                return (true, urlString)
            } else {
                return (false, nil)
            }
        } catch {
            print("Firebase Export Function Error: \(error.localizedDescription)")
            return (false, nil)
        }
    }
}
