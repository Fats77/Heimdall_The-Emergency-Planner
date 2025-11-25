//
//  ActiveAlertLandingView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 24/11/25.
//


import SwiftUI
import Foundation
import FirebaseFirestore
internal import Combine

/// This view shows the user what to do upon receiving an active alert.
struct ActiveAlertLandingView: View {
    let building: Building
    let emergencyType: EmergencyType
    
    // State to show floor list before instructions
    @State private var showFloorList = false
    
    var body: some View {
        VStack(spacing: 25) {
            Text("EMERGENCY ALERT: \(emergencyType.prettyType.uppercased())")
                .font(.title2.bold())
                .foregroundColor(.red)
                .padding(.top, 50)
            
            Text(building.name)
                .font(.title.bold())
            
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 100))
                .foregroundColor(.red)
            
            Text("Follow instructions to reach the assembly point.")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Primary Action Button
            Button {
                showFloorList = true
            } label: {
                Text("View Evacuation Instructions")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.theme)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .sheet(isPresented: $showFloorList) {
            // Option for floor before showing instructions (Point 1 requirement)
            FloorSelectionForInstructionView(building: building, emergencyType: emergencyType)
        }
    }
}

// Helper View to select a floor before viewing the specific instructions
struct FloorSelectionForInstructionView: View {
    let building: Building
    let emergencyType: EmergencyType
    
    @StateObject private var viewModel = FloorSelectionViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.floors) { floor in
                    // FIX: Pass the required String IDs, NOT the model objects.
                    NavigationLink(destination: InstructionDetailView(
                        buildingID: building.id!,
                        emergencyTypeID: emergencyType.id!
                        // NOTE: InstructionDetailView no longer expects floorID in the init,
                        // as per our previous fix using CollectionGroup query.
                    )) {
                        Text(floor.name)
                    }
                }
            }
            .navigationTitle("Select Your Floor")
            .onAppear {
                viewModel.fetchFloors(buildingID: building.id!)
            }
        }
    }
}

@MainActor
class FloorSelectionViewModel: ObservableObject {
    @Published var floors: [Floor] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchFloors(buildingID: String) {
        listener?.remove()
        
        let query = db.collection("buildings").document(buildingID).collection("floors")
            .order(by: "name")
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching floors for selector: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            self?.floors = documents.compactMap { try? $0.data(as: Floor.self) }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
