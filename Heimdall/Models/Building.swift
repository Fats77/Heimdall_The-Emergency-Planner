//
//  Building.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//

import Foundation
import FirebaseFirestore

struct Building: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let description: String?
    var buildingImageURL: String?
    var buildingMapURL: String?
    let inviteCode: String
    
    // let assemblyPoint: GeoPoint
    // let assemblyPointRadius: Double = 50.0
}

struct BuildingMember: Codable, Identifiable {
    @DocumentID var id: String? // This will be the user's UID
    let displayName: String
    let email: String
    var role: Role
    let uid: String
    var profilePhotoURL: String?
    
    // --- ADD CaseIterable ---
    enum Role: String, Codable, CaseIterable {
        case admin
        case coordinator
        case member
    }
}
