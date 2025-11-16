//
//  ContactCardView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 12/11/25.
//

import SwiftUI

struct ContactCardView: View {
    var name : String
    var body: some View {
        Text(name)
            .lineLimit(1)
//                                .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.primary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
}

#Preview {
    ContactCardView(name: "Father")
}
