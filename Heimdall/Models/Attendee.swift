//
//  Attendee.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore

struct Attendee: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var phone: String?
    var status: AttendeeStatus
    var safeTimestamp: Timestamp?
    var manuallyCheckedInBy: String?
}

enum AttendeeStatus: String, Codable, Hashable {
    case inProgress = "inProgress"
    case safe = "safe"
}
