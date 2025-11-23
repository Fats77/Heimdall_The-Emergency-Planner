//
//  CreateBuildingView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct CreateBuildingView: View {
    
    @StateObject private var viewModel = CreateBuildingViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    private let accentColor = Color(red: 0.23, green: 0.59, blue: 0.59)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create a Plan")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        Text("Start by defining your building or location.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - Card Container
                    VStack(spacing: 32) {
                        
                        // MARK: - Photo Picker
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Building Photo (Optional)")
                                .font(.title2.bold())
                            
                            // A simple Photo Picker
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
                                    } else {
                                        VStack {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                            Text("Tap to add a photo")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Description")
                                    .font(.headline)
                                
                                TextEditor(text: $viewModel.description)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .frame(minHeight: 100)
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            }
                        }
                        
                        // MARK: - Save Button
                        Button(action: {
                            Task {
                                // Call the save function in the ViewModel
                                let success = await viewModel.saveBuilding()
                                if success {
                                    dismiss() // Close the sheet/view
                                }
                            }
                        }) {
                            Text(viewModel.isLoading ? "Saving..." : "Create Building")
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.theme.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .disabled(viewModel.isLoading || viewModel.name.isEmpty) // Disable button while saving
                        
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.gray.opacity(0.6), radius: 5, x: 0, y: 2)
                }
                .padding()
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            // Show an alert if an error occurs
            .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { message in
                Button("OK") {}
            } message: { message in
                Text(message)
            }
        }
    }
}

#Preview {
    CreateBuildingView()
}
