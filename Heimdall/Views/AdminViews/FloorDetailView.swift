//
//  FloorDetailView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import SwiftUI
import Kingfisher
import FirebaseFirestore


// Assumed global models: Floor, EmergencyType, Building

struct FloorDetailView: View {
    
    let building: Building
    let floor: Floor
    
    @StateObject private var viewModel = FloorDetailViewModel()
    @State private var isAddingEmergencyType = false
    @State private var isShowingMapFullscreen = false
    @State private var isEditingEmergencyType: EmergencyType? // Used for editing an existing type
    
    var body: some View {
        List {
            // MARK: - Floor Map Section
            Section {
                VStack(alignment: .leading) {
                    // Display Floor Name / Level (instead of Main Entrance)
                    if !floor.name.isEmpty {
                        Text(floor.name)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }
                    
                    if let mapURLString = floor.floorMapURL, let url = URL(string: mapURLString) {
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .onTapGesture {
                                isShowingMapFullscreen = true // Tap to zoom
                            }
                    } else {
                        Text("No map has been uploaded for this floor.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .listRowBackground(Color.clear)
            
            // MARK: - Emergency Plans Section
            Section(header: Text("Emergency Plans")) {
                if viewModel.emergencyTypes.isEmpty {
                    EmptyStateView(symbol: "calendar", text: "No emergency plans added yet.")
                }
                
                ForEach(viewModel.emergencyTypes) { emergencyType in
                    HStack {
                        // FIX: Navigation Link to Instruction Detail View
                        NavigationLink(destination: InstructionDetailView(
                            buildingID: building.id!,
                            emergencyTypeID: emergencyType.id!
                        )) {
                            HStack {
                                Image(systemName: iconFor(emergencyType.type))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(colorFor(emergencyType.type))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading) {
                                    Text(emergencyType.prettyType)
                                        .font(.headline)
                                    Text("Drill: \(emergencyType.scheduleInterval.capitalized.replacingOccurrences(of: "_", with: " "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        
//                        // Edit Button (Admin/Coordinator)
//                        if viewModel.isAdmin || viewModel.isCoordinator {
//                            Button {
//                                isEditingEmergencyType = emergencyType
//                            } label: {
//                                Image(systemName: "pencil.circle.fill")
//                                    .foregroundColor(.gray)
//                                    .font(.title2)
//                            }
//                        }
                    }
                }
                .onDelete(perform: viewModel.deleteEmergencyType)
            }
        }
        .navigationTitle(floor.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddingEmergencyType = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(!viewModel.isAdmin) // Only Admins can add new plans
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton() // Enables swipe-to-delete for Admins
            }
        }
        // Sheet for Adding New Emergency Plan
        .sheet(isPresented: $isAddingEmergencyType) {
            NavigationStack {
                CreateEmergencyTypeView(
                    buildingID: building.id!,
                    floorID: floor.id!
                ) { newType in
                    // Callback to refresh the list when a new type is saved
                    viewModel.emergencyTypes.append(newType)
                }
            }
        }
        // Sheet for Editing Existing Emergency Plan
        .sheet(item: $isEditingEmergencyType) { emergencyType in
            NavigationStack {
                // TODO: Implement EditEmergencyTypeView to pre-populate data
                Text("Edit View for \(emergencyType.prettyType)")
            }
        }
        .sheet(isPresented: $isShowingMapFullscreen) {
            // Full-screen map view implementation
            FullscreenMapView(floor: floor)
        }
        .onAppear {
            viewModel.fetchData(buildingID: building.id!, floorID: floor.id!)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Returns a system icon name for each emergency type
    func iconFor(_ type: String) -> String {
        switch type {
        case "fire": return "flame.fill"
        case "earthquake": return "house.fill"
        case "tsunami": return "water.waves"
        default: return "exclamationmark.triangle.fill"
        }
    }
    
    /// Returns a color for each emergency type
    func colorFor(_ type: String) -> Color {
        switch type {
        case "fire": return .red
        case "earthquake": return .brown
        case "tsunami": return .blue
        default: return .gray
        }
    }
}

// MARK: - Fullscreen Map View
struct FullscreenMapView: View {
    let floor: Floor
    
    var body: some View {
        ZStack {
            if let mapURLString = floor.floorMapURL, let url = URL(string: mapURLString) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            } else {
                Text("Map not available.")
                    .foregroundColor(.white)
            }
        }
        .ignoresSafeArea()
    }
}
