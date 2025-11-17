//
//  EventService.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import FirebaseFunctions
import FirebaseFirestore

class EventService {
    
    static let shared = EventService()
    private var functions = Functions.functions()
    
    // Use this function in your TriggerAlertView
    func triggerAlert(building: CreateBuildingViewModel.Building, emergency: EmergencyType) async -> (Bool, String) {
        
        guard let buildingID = building.id,
              let emergencyTypeID = emergency.id else {
            return (false, "Missing local IDs.")
        }
        
        let data: [String: Any] = [
            "buildingId": buildingID,
            "emergencyTypeId": emergencyTypeID,
            "emergencyTypeName": emergency.prettyType // Pass the name for the notification
        ]
        
        do {
            // Call the cloud function by its name
            let result = try await functions.httpsCallable("triggerEmergencyAlert").call(data)
            
            // Handle the response from the function
            if let responseData = result.data as? [String: Any],
               let status = responseData["status"] as? String, status == "success" {
                let message = responseData["message"] as? String ?? "Alert triggered."
                print("Success: \(message)")
                return (true, message)
            } else {
                return (false, "Failed to trigger alert.")
            }
            
        } catch {
            // Handle specific Firebase errors
            let nsError = error as NSError
            if nsError.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: nsError.code)
                let message = nsError.localizedDescription
                print("Firebase Functions Error: \(message)")
                return (false, message)
            }
            
            print("Unknown Error: \(error.localizedDescription)")
            return (false, error.localizedDescription)
        }
    }
}