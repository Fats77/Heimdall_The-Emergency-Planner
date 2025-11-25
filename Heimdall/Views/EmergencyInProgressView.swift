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
        NavigationStack {
            VStack(spacing: 20) {
                Text("EMERGENCY IN PROGRESS")
                    .font(.title2.bold())
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
                Text(viewModel.emergencyType.prettyType.uppercased())
                    .font(.largeTitle.bold())
                
                // --- Instruction Button ---
                NavigationLink(destination: getInstructionDetailView()) {
                    Text("View Evacuation Instructions")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // TODO: Add Map View here showing user location and assembly points
                
                Spacer()
                
                // Display Current Status (Location tracking status)
                VStack {
                    Text("Tracking Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(locationManager.userLocation == nil ? "Locating..." : "Tracking Active")
                        .font(.body.bold())
                        .foregroundColor(locationManager.userLocation == nil ? .orange : .green)
                }
                .padding(.bottom, 20)
                
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
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func getInstructionDetailView() -> some View {
        // This view needs to pass the buildingID and the specific EmergencyType
        // It must also list the floors first, then the instructions for that floor.
        
        if let emergencyID = viewModel.emergencyType.id {
             // We can't know the specific floor without scanning all floors, so we take the user to the list
             InstructionDetailView(
                 buildingID: viewModel.buildingID,
                 emergencyTypeID: emergencyID
             )
        } else {
            Text("Error: Emergency plan ID not available.")
        }
    }
}
