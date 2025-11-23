//
//  CreateBuildingViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import PhotosUI
internal import Combine

@MainActor // Run all functions on the main thread
class CreateBuildingViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var description: String = ""
    
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            Task { await loadImage(from: selectedPhotoItem) }
        }
    }
    @Published var selectedImage: UIImage?
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    /// Loads a UIImage from a PhotosPickerItem
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.selectedImage = uiImage
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            self.errorMessage = "Could not load image. Please try again."
            self.showError = true
        }
    }
    
    /// Main function to save the building
    func saveBuilding() async -> Bool {
        isLoading = true
        
        // 1. Get current user details
        guard let userID = Auth.auth().currentUser?.uid,
              let userName = Auth.auth().currentUser?.displayName,
              let userEmail = Auth.auth().currentUser?.email
        else {
            self.errorMessage = "You must be logged in to create a building."
            self.showError = true
            self.isLoading = false
            return false
        }
        
        // 2. Validate input
        guard !name.isEmpty else {
            self.errorMessage = "Building name cannot be empty."
            self.showError = true
            self.isLoading = false
            return false
        }
        
        var buildingImageURL: String?
        
        // 3. Upload Photo (if one was selected)
        if let image = selectedImage {
            do {
                buildingImageURL = try await uploadPhoto(image: image, for: userID)
            } catch {
                self.errorMessage = "Error uploading photo: \(error.localizedDescription)"
                self.showError = true
                self.isLoading = false
                return false
            }
        }
        
        // 4. Save Building to Firestore
        do {
            // Create a new document in the 'buildings' collection
            let newBuildingRef = db.collection("buildings").document()
            let buildingID = newBuildingRef.documentID
            let inviteCode = generateInviteCode() // Generate unique code
            
            // Create the building document (FIX: Removed adminUserIDs field)
            let newBuilding = Building(
                id: buildingID,
                name: name,
                description: description.isEmpty ? nil : description,
                buildingImageURL: buildingImageURL,
                buildingMapURL: nil,
                inviteCode: inviteCode
            )
            
            // Save the building
            try newBuildingRef.setData(from: newBuilding)
            
            // 5. Add user as the admin in the 'members' subcollection (FIX: Used uid field)
            let adminMember = BuildingMember(
                id: userID,
                displayName: userName,
                email: userEmail,
                role: .admin,
                uid: userID // Use uid field
            )
            try await newBuildingRef.collection("members").document(userID).setData(from: adminMember)
            
            // 6. Add this building to the user's list of joined buildings
            try await db.collection("users").document(userID).updateData([
                "joinedBuildings": FieldValue.arrayUnion([buildingID])
            ])
            
            isLoading = false
            return true // Success!
            
        } catch {
            self.errorMessage = "Error saving building: \(error.localizedDescription)"
            self.showError = true
            self.isLoading = false
            return false
        }
    }
    
    /// Uploads a photo to Firebase Storage and returns the download URL
    private func uploadPhoto(image: UIImage, for userID: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "CreateBuildingViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])
        }
        
        let photoID = UUID().uuidString
        let storageRef = storage.reference().child("building_photos/temp/\(userID)/\(photoID).jpg")
        
        // Upload the data
        _ = try await storageRef.putDataAsync(imageData)
        
        // Get the download URL
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    /// Generates a simple 6-character invite code
    private func generateInviteCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map{ _ in letters.randomElement()! })
    }
}
