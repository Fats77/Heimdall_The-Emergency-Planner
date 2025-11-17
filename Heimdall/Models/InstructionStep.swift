//
//  InstructionStep.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation

struct InstructionStep: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var step: Int
    var title: String
    var description: String
    var imageURL: String?
}
