//
//  DrillCardView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 12/11/25.
//

import SwiftUI

struct DrillCardView: View {
    var name: String
    var body: some View {
        Text(name)
            .frame(width: 100, height: 150)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(0.8), Color(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundStyle(Color.primary)
            .cornerRadius(12)
            .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
    }
}

#Preview {
    DrillCardView(name: "Building 1")
}
