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

class EventService {
    
    static let shared = EventService()
    private var functions = Functions.functions(region: "us-central1")
    
    func triggerAlert(building: Building, emergency: EmergencyType) async -> (Bool, String) {
        
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
            _ = try await functions.httpsCallable("triggerEmergencyAlert").call(data)
            return (true, "Alert successfully triggered!")
        } catch {
            return (false, "Failed to trigger alert: \(error.localizedDescription)")
        }
    }
    
    func exportAttendance(buildingID: String, eventID: String) async -> (Bool, String?) {
        let data: [String: Any] = [
            "buildingId": buildingID,
            "eventId": eventID
        ]
        
        do {
            let result = try await functions.httpsCallable("exportAttendanceReport").call(data)
            
            if let responseData = result.data as? [String: Any],
               let downloadUrl = responseData["downloadUrl"] as? String {
                return (true, downloadUrl)
            } else {
                return (false, "Failed to get download URL from server.")
            }
        } catch {
            print("Error exporting report: \(error.localizedDescription)")
            return (false, nil)
        }
    }
}
