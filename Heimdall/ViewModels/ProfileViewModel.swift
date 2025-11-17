//
//  ProfileViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
internal import Combine

struct AlertError: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
class ProfileViewModel: ObservableObject {
    
    // --- Published Properties for UI ---
    @Published var name: String = ""
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var profilePhotoURL: URL?
    
    // --- Image Picker State ---
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedPhotoItem) } }
    }
    @Published var selectedImage: UIImage? // The new image the user picked
    
    // --- View State ---
    @Published var isLoading = false
    @Published var errorMessage: AlertError?
    
    // --- Firebase Services ---
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    private var authUser: User? // The Firebase Auth user
    
    /// 1. Load User Data
    /// Fetches data from both Auth (for name/email/photo) and Firestore (for phone)
    func loadUserData(from authService: AuthService) {
        guard let user = authService.currentUser else {
            showError(message: "Could not find user.")
            return
        }
        self.authUser = user
        
        // Load from Auth
        self.name = user.displayName ?? ""
        self.email = user.email ?? "No Email"
        self.profilePhotoURL = user.photoURL
        
        // Load from Firestore
        Task {
            do {
                let userDoc = try await db.collection("users").document(user.uid)
                                        .getDocument(as: AppUser.self)
                
                self.phoneNumber = userDoc.phoneNumber ?? ""
                
            } catch {
                print("Could not load user's phone number: \(error.localizedDescription)")
            }
        }
    }
    
    /// 2. Save Profile Data
    /// A 3-step process: Upload Image, Update Auth, Update Firestore
    func saveProfile() async {
        guard let user = authUser else {
            showError(message: "User not found.")
            return
        }
        
        isLoading = true
        
        do {
            var newPhotoURL: URL? = self.profilePhotoURL
            
            if let image = selectedImage {
                newPhotoURL = try await uploadPhoto(image: image, for: user.uid)
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.photoURL = newPhotoURL
            try await changeRequest.commitChanges()
            
            let userRef = db.collection("users").document(user.uid)
            try await userRef.updateData([
                "name": name,
                "phoneNumber": phoneNumber,
                "profilePhotoURL": newPhotoURL?.absoluteString ?? FieldValue.delete()
            ])
            
            print("Profile successfully updated!")
            
        } catch {
            showError(message: "Failed to save profile: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// 3. Sign Out
    func signOut(from authService: AuthService) {
        authService.signOut()
    }
    
    // MARK: - Helper Functions
    
    /// Uploads a photo to Storage and returns the download URL
    private func uploadPhoto(image: UIImage, for userID: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ProfileViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])
        }
        
        let storageRef = storage.reference().child("profile_photos/\(userID).jpg")
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL
    }
    
    /// Loads a UIImage from the PhotosPickerItem
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            self.selectedImage = UIImage(data: data)
        }
    }
    
    /// Opens the app's settings in the iOS Settings app
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Helper to show an error
    private func showError(message: String) {
        self.errorMessage = AlertError(message: message)
    }
}
