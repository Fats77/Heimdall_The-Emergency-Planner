//
//  EmergencyInProgressView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
internal import Combine

struct EmergencyInProgressView: View {
    @ObservedObject var viewModel: ActiveEmergencyViewModel
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("EMERGENCY IN PROGRESS")
                .font(.title2.bold())
                .foregroundColor(.red)
                .padding()
            
            Text(viewModel.emergencyType.prettyType.uppercased())
                .font(.largeTitle.bold())
            
            // TODO: Add a map view here showing user location and assembly points
            
            // List of Instructions
            List {
                Section("Instructions") {
                    ForEach(viewModel.instructions) { step in
                        Text("\(step.step). \(step.title)")
                    }
                }
            }
            
            Spacer()
            
            // Manual "I am Safe" button
            Button {
                viewModel.markUserAsSafe()
            } label: {
                Text("I AM SAFE")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}
