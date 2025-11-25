//
//  EmergencyType.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore

struct EmergencyType: Identifiable, Codable , Equatable{
    @DocumentID var id: String?
    var type: String // "fire", "earthquake", "tsunami"
    var scheduleDay: Int
    var scheduleTime: String // Storing as "HH:mm"
    var scheduleInterval: String // "every_month", etc.
    
    var assemblyPoints: [AssemblyPoint]?
    var instructions: [InstructionStep]?
    
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
    
    static func == (lhs: EmergencyType, rhs: EmergencyType) -> Bool {
            return lhs.id == rhs.id
        }
}
