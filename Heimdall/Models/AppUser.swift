//
//  AppUser.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable {
    var uid: String
    var name: String
    var email: String
    var phoneNumber: String?
    var profilePhotoURL: String?
    var joinedBuildings: [String]
}
