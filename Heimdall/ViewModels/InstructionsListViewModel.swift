//
//  InstructionsListViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
internal import Combine
import SwiftUI

@MainActor
class InstructionsListViewModel: ObservableObject {
    
    @Published var editableSteps: [InstructionStep] = []
    @Published var isEditing: Bool = false
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    let buildingID: String
    private let emergencyTypeID: String
    private var db = Firestore.firestore()
    private var storage = FirebaseStorage.Storage.storage()
    
    init(buildingID: String, emergencyTypeID: String) {
        self.buildingID = buildingID
        self.emergencyTypeID = emergencyTypeID
    }
    
    // Loads the data received from the InstructionDetailViewModel's fetch
    func loadInitialInstructions(from steps: [InstructionStep]?) {
        self.editableSteps = steps?.sorted { $0.step < $1.step } ?? []
    }
    
    // MARK: - List Management (FIXED Signatures)
    
    /// Called by .onDelete (takes IndexSet)
    func deleteStep(at offsets: IndexSet) {
        editableSteps.remove(atOffsets: offsets)
    }
    
    /// Called by .onMove (takes IndexSet, Int)
    func moveStep(from source: IndexSet, to destination: Int) {
        editableSteps.move(fromOffsets: source, toOffset: destination)
        // Note: Changes are persisted only when user taps "Save Changes"
    }
    
    // ... (rest of the ViewModel methods remain the same, including uploadPhoto and saveChanges) ...
    
    // The rest of the VM methods are assumed to be present and correct from prior steps.
    
    func uploadPhoto(image: UIImage, for buildingID: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data.")
            return nil
        }
        
        do {
            let photoID = UUID().uuidString
            let storageRef = storage.reference().child("instruction_photos/\(buildingID)/\(photoID).jpg")
            
            _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            print("Error uploading instruction image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateExistingStep(_ updatedStep: InstructionStep) {
        if let index = editableSteps.firstIndex(where: { $0.id == updatedStep.id }) {
            editableSteps[index] = updatedStep
        }
    }
    
    func addNewStep(_ newStep: InstructionStep) {
        let nextStep = (editableSteps.last?.step ?? 0) + 1
        var finalStep = newStep
        finalStep.step = nextStep
        editableSteps.append(finalStep)
    }
    
    /// Re-numbers and saves the entire list to Firestore
    func saveChanges() {
        isLoading = true
        
        let stepsToSave = editableSteps.enumerated().map { (index, step) -> [String: Any] in
            return [
                "id": step.id,
                "step": index + 1, // Recalculated step number
                "title": step.title,
                "description": step.description,
                "imageURL": step.imageURL as Any
            ]
        }
        
        let docRefQuery = db.collectionGroup("emergencyTypes")
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: "buildings/\(buildingID)/")
            .whereField(FieldPath.documentID(), isLessThan: "buildings/\(buildingID)0")
            
        docRefQuery.getDocuments { [weak self] snapshot, _ in
            guard let doc = snapshot?.documents.first(where: { $0.documentID == self?.emergencyTypeID }) else {
                self?.showError(message: "Failed to locate emergency plan for update.")
                return
            }
            
            doc.reference.updateData(["instructions": stepsToSave]) { error in
                if let error = error {
                    self?.showError(message: "Error saving instructions: \(error.localizedDescription)")
                } else {
                    self?.updateLocalSteps(from: stepsToSave)
                }
                self?.isLoading = false
            }
        }
    }
    
    // After save, update the local steps with correct step numbers
    private func updateLocalSteps(from data: [[String: Any]]) {
        self.editableSteps = data.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let step = dict["step"] as? Int,
                  let title = dict["title"] as? String,
                  let description = dict["description"] as? String else { return nil }
            
            return InstructionStep(
                id: id,
                step: step,
                title: title,
                description: description,
                imageURL: dict["imageURL"] as? String
            )
        }.sorted { $0.step < $1.step }
    }
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
        self.isLoading = false
    }
}
