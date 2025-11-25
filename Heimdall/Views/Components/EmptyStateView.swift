//
//  EmptyStateView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 25/11/25.
//

import SwiftUI

struct EmptyStateView: View {
    var symbol: String = "door.garage.open.trianglebadge.exclamationmark"
    var text: String = "No data yet."
    var body: some View {
        VStack(spacing: 10){
            Image(systemName: symbol)
                .font(.title)
            Text(text)
                .font(.body)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black, style: StrokeStyle(
                    lineWidth: 1,
                    dash: [10, 5],
                    dashPhase: 0
                ))
        }
        .opacity(0.2)
    }
}

#Preview {
    EmptyStateView()
}
