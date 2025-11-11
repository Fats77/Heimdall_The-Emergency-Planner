//
//  Drill.swift
//  Heimdall
//
//  Created by Kemas Deanova on 11/11/25.
//

import Foundation
import FirebaseFirestore

// This model goes in the "buildings/{buildingId}/drills" sub-collection
struct Drill: Codable, Identifiable {
    @DocumentID var id: String?
    let emergencyType: EmergencyType
    let interval: DrillInterval
    let scheduleDay: Int // e.g., 15 (for 15th of the month)
    let scheduleTime: String // e.g., "14:30"
    
    // This is the 1-to-Many relationship you described
    var instructions: [Instruction]
    
    enum EmergencyType: String, Codable, CaseIterable, Identifiable {
        case fire = "Fire"
        case earthquake = "Earthquake"
        case tsunami = "Tsunami"
        var id: String { self.rawValue }
    }
    
    enum DrillInterval: String, Codable, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case threeTimesPerYear = "Three times a year"
        case twicePerYear = "Twice a year"
        case yearly = "Yearly"
        var id: String { self.rawValue }
    }
}

// This is part of the Drill model, not a separate collection
struct Instruction: Codable, Identifiable {
    let id: UUID // Use UUID to identify it *within the array*
    var title: String
    var description: String
    var imageURL: String?
}
