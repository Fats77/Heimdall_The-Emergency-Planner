//
//  InstructionsListViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import Foundation
import FirebaseFirestore
internal import Combine

@MainActor
class InstructionsListViewModel: ObservableObject {
    
    @Published var instructionSteps: [InstructionStep] = []
    @Published var hasChanges = false
    
    private var db = Firestore.firestore()
    
    // Store IDs
    private var buildingID: String?
    private var floorID: String?
    private var emergencyTypeID: String?
    
    /// Fetches the instructions array from the EmergencyType document
    func fetchInstructions(buildingID: String, floorID: String, emergencyTypeID: String) {
        self.buildingID = buildingID
        self.floorID = floorID
        self.emergencyTypeID = emergencyTypeID
        
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("floors").document(floorID)
                       .collection("emergencyTypes").document(emergencyTypeID)
        
        docRef.getDocument(as: EmergencyType.self) { [weak self] result in
            switch result {
            case .success(let emergencyType):
                // We also need to get the instructions array
                // This requires a separate data fetch or a different model
                docRef.getDocument { snapshot, error in
                    guard let data = snapshot?.data(),
                          let instructionsData = data["instructions"] as? [[String: Any]] else {
                        // No instructions yet, which is fine
                        self?.instructionSteps = []
                        return
                    }
                    
                    // Decode the array of dictionaries into our struct
                    var steps: [InstructionStep] = []
                    for stepData in instructionsData {
                        if let step = self?.decodeStep(from: stepData) {
                            steps.append(step)
                        }
                    }
                    // Sort by the 'step' field
                    self?.instructionSteps = steps.sorted { $0.step < $1.step }
                }
                
            case .failure(let error):
                print("Error fetching emergency type: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper to decode dictionary to InstructionStep
    private func decodeStep(from data: [String: Any]) -> InstructionStep? {
        // Simple manual decoding
        guard let id = data["id"] as? String,
              let step = data["step"] as? Int,
              let title = data["title"] as? String,
              let description = data["description"] as? String else {
            return nil
        }
        let imageURL = data["imageURL"] as? String
        return InstructionStep(id: id, step: step, title: title, description: description, imageURL: imageURL)
    }

    /// Adds a new step to the local array
    func addStep(_ step: InstructionStep) {
        var newStep = step
        newStep.step = (instructionSteps.last?.step ?? 0) + 1
        instructionSteps.append(newStep)
        hasChanges = true
    }
    
    /// Deletes a step from the local array
    func deleteStep(at offsets: IndexSet) {
        instructionSteps.remove(atOffsets: offsets)
        hasChanges = true
    }
    
    /// Moves a step in the local array
    func moveStep(from source: IndexSet, to destination: Int) {
        instructionSteps.move(fromOffsets: source, toOffset: destination)
        hasChanges = true
    }
    
    /// Saves all changes back to Firestore
    func saveChanges() {
        guard let buildingID = buildingID, let floorID = floorID, let emergencyTypeID = emergencyTypeID else {
            print("Error: Missing IDs")
            return
        }
        
        // 1. Re-number all steps to ensure they are sequential
        let stepsToSave = instructionSteps.enumerated().map { (index, step) -> InstructionStep in
            var updatedStep = step
            updatedStep.step = index + 1
            return updatedStep
        }
        
        // 2. Convert array of structs to an array of dictionaries for Firebase
        let stepsData = stepsToSave.map { step -> [String: Any] in
            [
                "id": step.id,
                "step": step.step,
                "title": step.title,
                "description": step.description,
                "imageURL": step.imageURL as Any
            ]
        }
        
        // 3. Update the 'instructions' field in the document
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("floors").document(floorID)
                       .collection("emergencyTypes").document(emergencyTypeID)
        
        docRef.updateData(["instructions": stepsData]) { [weak self] error in
            if let error = error {
                print("Error saving changes: \(error.localizedDescription)")
                // TODO: Show an alert
            } else {
                print("Successfully saved instructions!")
                self?.instructionSteps = stepsToSave // Update local array with new step numbers
                self?.hasChanges = false
            }
        }
    }
}
