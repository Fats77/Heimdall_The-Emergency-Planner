//
//  CustomButtonView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 27/10/25.
//

import SwiftUI

struct CustomButtonView: View {
    let label: String
    var body: some View {
        Text(label)
            .padding(.vertical)
            .padding(.horizontal, 20)
            .background{
                PrimaryGradientView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .foregroundStyle(.white)
    }
}

#Preview {
    CustomButtonView(label: "Custom Button")
}
