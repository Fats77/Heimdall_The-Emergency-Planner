//
//  Floor.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore

struct Floor: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var floorMapURL: String?
}
