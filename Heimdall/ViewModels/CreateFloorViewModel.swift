//
//  CreateFloorViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
internal import Combine

@MainActor
class CreateFloorViewModel: ObservableObject {
    
    @Published var floorName: String = ""
    
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedPhotoItem) } }
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
            showError(error)
        }
    }
    
    /// Main function to save the floor
    func saveFloor(buildingID: String) async -> Floor? {
        isLoading = true
        
        guard !floorName.isEmpty else {
            showError(message: "Floor name cannot be empty.")
            return nil
        }
        
        var floorMapURL: String?
        
        // 1. Upload Photo (if one was selected)
        if let image = selectedImage {
            do {
                floorMapURL = try await uploadMap(image: image, for: buildingID)
            } catch {
                showError(error)
                return nil
            }
        }
        
        // 2. Save Floor to Firestore
        do {
            // Create a new document in the 'floors' subcollection
            let newFloorRef = db.collection("buildings").document(buildingID).collection("floors").document()
            
            var newFloor = Floor(
                id: newFloorRef.documentID,
                name: floorName,
                floorMapURL: floorMapURL
            )
            
            try newFloorRef.setData(from: newFloor)
            
            isLoading = false
            return newFloor // Success!
            
        } catch {
            showError(error)
            return nil
        }
    }
    
    /// Uploads a map to Firebase Storage
    private func uploadMap(image: UIImage, for buildingID: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "CreateFloorViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])
        }
        
        let mapID = UUID().uuidString
        let storageRef = storage.reference().child("floor_maps/\(buildingID)/\(mapID).jpg")
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    /// Helper to show errors
    private func showError(_ error: Error? = nil, message: String? = nil) {
        errorMessage = error?.localizedDescription ?? message ?? "An unknown error occurred."
        showError = true
        isLoading = false
    }
}
