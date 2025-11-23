//
//  AssemblyPoint.swift
//  Heimdall
//
//  Created by Kemas Deanova on 21/11/25.
//

import Foundation
import FirebaseFirestore

struct AssemblyPoint: Codable, Identifiable {
    var id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
}
