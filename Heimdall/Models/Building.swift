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
    let description: String
    var buildingImageURL: String?
    var buildingMapURL: String?
    let inviteCode: String
    
    // let assemblyPoint: GeoPoint
    // let assemblyPointRadius: Double = 50.0
}

struct BuildingMember: Codable, Identifiable {
    @DocumentID var id: String?
    let displayName: String
    let email: String
    var role: Role
    
    enum Role: String, Codable {
        case admin
        case coordinator
        case member
    }
}
