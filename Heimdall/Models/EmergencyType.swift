//
//  EmergencyType.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore

struct EmergencyType: Identifiable, Codable {
    @DocumentID var id: String?
    var type: String // "fire", "earthquake", "tsunami"
    var scheduleDay: Int
    var scheduleTime: String // Storing as "HH:mm"
    var scheduleInterval: String // "every_month", etc.
    
    // We'll add assemblyPoints and instructions later
    
    // Helper property for display
    var prettyType: String {
        type.capitalized
    }
    
    static func placeholder() -> EmergencyType {
            return EmergencyType(
                id: "placeholder",
                type: "Loading...",
                scheduleDay: 1,
                scheduleTime: "12:00",
                scheduleInterval: "every_month"
            )
        }
}
