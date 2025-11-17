//
//  Event.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var eventName: String
    var emergencyTypeID: String
    var startTime: Timestamp
    var endTime: Timestamp?
    var status: Status // <-- Now this will work
    var triggeredBy: String
    var type: String // 'drill' or 'alert'
    
    // --- THIS IS THE MISSING ENUM ---
    enum Status: String, Codable {
        case active = "active"
        case completed = "completed"
    }
}
