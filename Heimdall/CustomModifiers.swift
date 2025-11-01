//
//  CustomModifiers.swift
//  Heimdall
//
//  Created by Kemas Deanova on 31/10/25.
//
import SwiftUI
import Foundation

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
