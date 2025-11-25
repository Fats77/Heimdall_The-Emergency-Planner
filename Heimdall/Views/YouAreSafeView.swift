//
//  YouAreSafeView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
internal import Combine

struct YouAreSafeView: View {
    @ObservedObject var viewModel: ActiveEmergencyViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("You Are Marked as Safe")
                .font(.largeTitle.bold())
            
            Text("Your location is no longer being tracked. Please wait for further instructions from your coordinator.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                viewModel.markUserAsNotSafe() // Allow un-doing
            } label: {
                Text("Mark Me As Missing")
                    .foregroundColor(.red)
            }
        }
    }
}
