//
//  EditBuildingViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 21/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
internal import Combine

@MainActor
class EditBuildingViewModel: ObservableObject {
    
    @Published var name: String
    @Published var description: String
    @Published var currentPhotoURL: URL? // URL of the photo currently saved in Firestore
    
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            Task { await loadImage(from: selectedPhotoItem) }
        }
    }
    @Published var selectedImage: UIImage? // The new image data
    @Published var photoWasRemoved = false // Flag if user deleted the old image
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var buildingID: String
    private var originalBuilding: Building
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // Use the global Building model
    init(building: Building) {
        self.originalBuilding = building
        self.buildingID = building.id ?? ""
        self.name = building.name
        self.description = building.description ?? ""
        
        // FIX: Use buildingImageURL
        if let urlString = building.buildingImageURL, let url = URL(string: urlString) {
            self.currentPhotoURL = url
        }
    }
    
    /// Clears the photo/selection and flags for removal upon save
    func removePhoto() {
        currentPhotoURL = nil
        selectedImage = nil
        selectedPhotoItem = nil
        photoWasRemoved = true
    }
    
    /// Loads a UIImage from a PhotosPickerItem
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.selectedImage = uiImage
                    self.photoWasRemoved = false // A new photo overrides removal flag
                }
            }
        } catch {
            self.errorMessage = "Could not load image. Please try again."
            self.showError = true
        }
    }
    
    /// Saves all changes back to Firestore and Storage
    func saveChanges() async -> Bool {
        isLoading = true
        
        guard !name.isEmpty else {
            self.errorMessage = "Building name cannot be empty."
            self.showError = true
            self.isLoading = false
            return false
        }
        
        var finalPhotoURL: String? = originalBuilding.buildingImageURL
        
        do {
            // 1. Handle Photo Changes
            if photoWasRemoved {
                // Delete the old photo from storage if one existed
                if let oldUrl = originalBuilding.buildingImageURL {
                    // TODO: Implement actual Storage deletion logic if necessary
                    print("TODO: Deleting old photo at \(oldUrl)")
                }
                finalPhotoURL = nil
                
            } else if let image = selectedImage {
                // Upload New Photo
                finalPhotoURL = try await uploadPhoto(image: image)
                
            } else if currentPhotoURL != nil {
                // Retain old URL if no changes were made and photo wasn't marked for removal
                finalPhotoURL = originalBuilding.buildingImageURL
            }
            
            // 2. Prepare Data Update
            let updatedData: [String: Any?] = [
                "name": name,
                "description": description,
                "buildingImageURL": finalPhotoURL // FIX: Changed to buildingImageURL
            ]
            
            // 3. Update Firestore
            let docRef = db.collection("buildings").document(buildingID)
            // compactMapValues removes nil keys (which handles deleting the photoURL if finalPhotoURL is nil)
            try await docRef.updateData(updatedData.compactMapValues { $0 })
            
            isLoading = false
            return true
            
        } catch {
            self.errorMessage = "Error saving changes: \(error.localizedDescription)"
            self.showError = true
            self.isLoading = false
            return false
        }
    }
    
    /// Uploads a photo to Firebase Storage and returns the download URL
    private func uploadPhoto(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "EditBuildingViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])
        }
        
        let photoID = UUID().uuidString
        let storageRef = storage.reference().child("building_photos/\(buildingID)/\(photoID).jpg")
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
