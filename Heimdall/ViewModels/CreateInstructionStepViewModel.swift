//
//  CreateInstructionStepViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
internal import Combine

@MainActor
class CreateInstructionStepViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedPhotoItem) } }
    }
    @Published var selectedImage: UIImage?
    
    @Published var isLoading = false
    
    private var storage = Storage.storage()
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            self.selectedImage = UIImage(data: data)
        }
    }
    
    func save(buildingID: String) async -> InstructionStep? {
        isLoading = true
        var imageURL: String?
        
        // 1. Upload image if it exists
        if let image = selectedImage {
            do {
                imageURL = try await uploadPhoto(image: image, buildingID: buildingID)
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
                isLoading = false
                return nil // TODO: Show error
            }
        }
        
        // 2. Create the step
        let newStep = InstructionStep(
            step: 0, // The ViewModel will set the correct step number
            title: title,
            description: description,
            imageURL: imageURL
        )
        
        isLoading = false
        return newStep
    }
    
    private func uploadPhoto(image: UIImage, buildingID: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])
        }
        
        let photoID = UUID().uuidString
        let storageRef = storage.reference().child("instruction_photos/\(buildingID)/\(photoID).jpg")
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
