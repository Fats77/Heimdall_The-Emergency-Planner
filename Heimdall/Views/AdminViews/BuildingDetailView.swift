//
//  BuildingDetailView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct BuildingDetailView: View {
    // This view now creates its own ViewModel
    @StateObject private var viewModel: BuildingDetailViewModel
    
    let building: CreateBuildingViewModel.Building
    
    @State private var isAddingFloor = false
    
    // State for presenting the alert confirmation
    @State private var selectedEmergency: EmergencyType?
    @State private var floors: [Floor] = []
    
    // We initialize the ViewModel with the building's ID
    init(building: CreateBuildingViewModel.Building) {
        self.building = building
        _viewModel = StateObject(wrappedValue: BuildingDetailViewModel(buildingID: building.id!))
    }
    
    var body: some View {
        List {
            // MARK: - Header Section
            Section {
                // ... (This section is unchanged from before) ...
                // It shows the photo, name, description, and invite code
            }
            .listRowBackground(Color.clear)
            
            // MARK: - ADMIN CONTROLS SECTION
            // This is the new section!
            if viewModel.isAdmin {
                Section(header: Text("Admin Controls"),
                        footer: Text("Select an emergency plan to send an immediate alert to all members.")) {
                    
                    if viewModel.allEmergencyTypes.isEmpty {
                        Text("No emergency plans created yet.")
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(viewModel.allEmergencyTypes) { emergency in
                        Button {
                            // 1. Tapping this selects the emergency
                            self.selectedEmergency = emergency
                        } label: {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Trigger \(emergency.prettyType) Alert")
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // MARK: - Floors Section
            Section(header: Text("Floors")) {
                if viewModel.floors.isEmpty {
                    Text("No floors added yet.")
                        .foregroundColor(.secondary)
                }
                
                ForEach(viewModel.floors) { floor in
                    // This navigation link is now correct
                    NavigationLink(destination: FloorDetailView(building: building, floor: floor)) {
                        HStack {
                            Image(systemName: "map")
                                .foregroundColor(.accentColor)
                            Text(floor.name)
                        }
                    }
                }
                .onDelete(perform: deleteFloor) // This should be moved to the ViewModel
            }
            
            // ... (Members Section is unchanged) ...
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isAdmin { // Only show "Add Floor" to admins
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddingFloor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingFloor) {
            NavigationStack {
                CreateFloorView(buildingID: building.id!) { newFloor in
                    self.floors.append(newFloor)
                }
            }
        }
        // 2. This sheet is presented when an emergency is selected
        .sheet(item: $selectedEmergency) { emergency in
            TriggerAlertView(building: building, emergency: emergency)
                .presentationDetents([.medium])
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    func deleteFloor(at offsets: IndexSet) {
        // TODO: Move this logic into the ViewModel
        print("Delete floor at \(offsets)")
    }
}

#Preview {
//    BuildingDetailView()
}
