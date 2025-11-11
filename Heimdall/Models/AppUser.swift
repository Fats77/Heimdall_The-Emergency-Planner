//
//  AppUser.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let displayName: String
    var emergencyContacts: [EmergencyContact]?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: displayName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

struct EmergencyContact: Codable {
    let name: String
    let phone: String
}
