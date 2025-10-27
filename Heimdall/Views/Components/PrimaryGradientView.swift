//
//  PrimaryGradient.swift
//  Heimdall
//
//  Created by Kemas Deanova on 27/10/25.
//

import SwiftUI

struct PrimaryGradientView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.secondary2, .theme]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    PrimaryGradientView()
}
