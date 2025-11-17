//
//  FloorDetailView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import SwiftUI
import Kingfisher
import FirebaseFirestore

struct FloorDetailView: View {
    // Pass in the building and floor
    let building: CreateBuildingViewModel.Building
    let floor: Floor
    
    @StateObject private var viewModel = FloorDetailViewModel()
    @State private var isAddingEmergencyType = false
    
    var body: some View {
        List {
            // MARK: - Floor Map Section
            Section {
                if let mapURLString = floor.floorMapURL, let url = URL(string: mapURLString) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .listRowInsets(EdgeInsets())
                } else {
                    Text("No map has been uploaded for this floor.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listRowBackground(Color.clear)
            
            // MARK: - Emergency Plans Section
            Section(header: Text("Emergency Plans")) {
                if viewModel.emergencyTypes.isEmpty {
                    Text("No emergency plans added yet.")
                        .foregroundColor(.secondary)
                }
                
                ForEach(viewModel.emergencyTypes) { emergencyType in
                    // Tapping here will go to the Instructions list
                    NavigationLink(destination: Text("Instructions for \(emergencyType.prettyType)")) {
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
                                Text("Drill: \(emergencyType.scheduleInterval.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
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
            }
        }
        // This is where we link your refactored view!
        .sheet(isPresented: $isAddingEmergencyType) {
            NavigationStack {
                // Pass in the IDs
                CreateEmergencyTypeView(
                    buildingID: building.id!,
                    floorID: floor.id!
                ) { newType in
                    // This is our callback
                    viewModel.emergencyTypes.append(newType)
                }
            }
        }
        .onAppear {
            // Load the data when the view appears
            viewModel.fetchEmergencyTypes(buildingID: building.id!, floorID: floor.id!)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Returns a system icon name for each emergency type
    func iconFor(_ type: String) -> String {
        switch type {
        case "fire": return "flame.fill"
        case "earthquake": return "house.fill" // iOS 16+ has "water.waves.and.arrow.down"
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