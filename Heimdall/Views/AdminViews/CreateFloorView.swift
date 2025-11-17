//
//  CreateFloorView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import PhotosUI

struct CreateFloorView: View {
    
    // The ID of the building we're adding a floor to
    let buildingID: String
    
    // A "callback" closure to pass the new floor back to the detail view
    var onSave: (Floor) -> Void
    
    @StateObject private var viewModel = CreateFloorViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Floor Details")) {
                TextField("Floor Name (e.g., 'Ground Floor' or 'Level 2')", text: $viewModel.floorName)
            }
            
            Section(header: Text("Floor Map")) {
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(12)
                    } else {
                        // This is your "Upload the map" button
                        HStack {
                            Text("Upload the map")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                                .font(.title2).bold()
                                .foregroundColor(.accentColor)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .navigationTitle("Add New Floor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveFloor()
                }
                // Disable save button if loading or no name
                .disabled(viewModel.isLoading || viewModel.floorName.isEmpty)
            }
        }
        .overlay {
            // Show a loading spinner
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { message in
            Button("OK") {}
        } message: { message in
            Text(message)
        }
    }
    
    func saveFloor() {
        Task {
            // Call the ViewModel to save the data
            let newFloor = await viewModel.saveFloor(buildingID: buildingID)
            
            if let newFloor = newFloor {
                // If save was successful, call the closure...
                onSave(newFloor)
                // ...and close the view
                dismiss()
            }
        }
    }
}

#Preview {
//    CreateFloorView()
}
