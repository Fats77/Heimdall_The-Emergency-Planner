//
//  EditBuildingView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 21/11/25.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct EditBuildingView: View {
    
    // Using the global Building model now
    let building: Building
    
    @StateObject private var viewModel: EditBuildingViewModel
    @Environment(\.dismiss) var dismiss
    
    init(building: Building) {
        self.building = building
        _viewModel = StateObject(wrappedValue: EditBuildingViewModel(building: building))
    }
    
    private let accentColor = Color(red: 0.23, green: 0.59, blue: 0.59)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Edit Plan Details")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    Text("Update building information and primary photo.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // MARK: - Card container
                VStack(spacing: 32) {
                    
                    // MARK: - Photo Picker
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Building Photo (Optional)")
                            .font(.title2.bold())
                        
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .frame(height: 200)
                                
                                if let image = viewModel.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(12)
                                } else if let photoURL = viewModel.currentPhotoURL {
                                    // FIX: Use KFImage for existing photo
                                    KFImage(photoURL)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    VStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                        Text("Tap to change photo")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                        // Delete Photo Button (only if a photo exists)
                        if viewModel.currentPhotoURL != nil || viewModel.selectedImage != nil {
                            Button("Remove Photo", role: .destructive) {
                                viewModel.removePhoto()
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    // MARK: - Details Section
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Details")
                            .font(.title2.bold())
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Building Name")
                                .font(.headline)
                            
                            TextField("e.g., Central Office Tower", text: $viewModel.name)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Description")
                                .font(.headline)
                            
                            TextEditor(text: $viewModel.description)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .frame(minHeight: 100)
                        }
                    }
                    
                    // MARK: - Save Button
                    Button(action: {
                        Task {
                            let success = await viewModel.saveChanges()
                            if success {
                                dismiss() // Close the sheet/view
                            }
                        }
                    }) {
                        Text(viewModel.isLoading ? "Saving..." : "Save Changes")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                    }
                    .disabled(viewModel.isLoading || viewModel.name.isEmpty)
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.gray.opacity(0.6), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Edit Plan")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { message in
            Button("OK") {}
        } message: { message in
            Text(message)
        }
    }
}
