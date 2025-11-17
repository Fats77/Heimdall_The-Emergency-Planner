//
//  ProfileView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 02/11/25.
//

import SwiftUI
import PhotosUI
import Kingfisher // Make sure to add this package

struct ProfileView: View {
    
    // The ViewModel will handle all logic
    @StateObject private var viewModel = ProfileViewModel()
    
    // Get the global auth service
    @EnvironmentObject var authService: AuthService
    
    // To close the sheet
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Profile Section
                Section(header: Text("Profile")) {
                    // --- Photo Picker ---
                    HStack {
                        Spacer()
                        VStack {
                            PhotosPicker(
                                selection: $viewModel.selectedPhotoItem,
                                matching: .images
                            ) {
                                // Show selected image, or current photo, or placeholder
                                ZStack(alignment: .bottomTrailing) {
                                    if let image = viewModel.selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                    } else if let photoURL = viewModel.profilePhotoURL {
                                        KFImage(photoURL) // Use Kingfisher
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                
                                // --- "Pencil" Icon ---
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    // --- Name Field ---
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.name)
                    
                    // --- Phone Field (Key Requirement) ---
                    TextField("Phone Number", text: $viewModel.phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    // --- Email (Read-only) ---
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(viewModel.email)
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Settings Section
                Section(header: Text("Settings")) {
                    // This is the correct way to handle notification settings
                    Button {
                        viewModel.openAppSettings()
                    } label: {
                        Label("Notifications", systemImage: "bell.fill")
                            .foregroundColor(.primary) // Keep default label color
                    }
                }
                
                // MARK: - Actions Section
                Section {
                    Button(role: .destructive) {
                        viewModel.signOut(from: authService)
                    } label: {
                        Text("Log Out")
                    }
                }
            }
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // --- Cancel Button ---
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // --- Save Button ---
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveProfile()
                            dismiss() // Close sheet after saving
                        }
                    }
                    .disabled(viewModel.isLoading) // Disable while saving
                }
            }
            .onAppear {
                // Load the user's data when the view appears
                viewModel.loadUserData(from: authService)
            }
            // Show an alert if saving fails
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { error in
                Button("OK") {
                    viewModel.errorMessage = nil 
                }
            } message: { error in
                Text(error.message)
            }
        }
    }
}

#Preview {
    ProfileView()
}
