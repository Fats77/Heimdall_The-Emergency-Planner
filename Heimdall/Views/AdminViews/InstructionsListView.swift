//
//  InstructionsListView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import FirebaseFirestore

struct InstructionsListView: View {
    // Pass in the IDs of the parent documents
    let buildingID: String
    let floorID: String
    let emergencyType: EmergencyType // We pass the whole object for context
    
    // FIX: Initialize the ViewModel using the required IDs
    @StateObject private var viewModel: InstructionsListViewModel
    @State private var isAddingStep = false
    
    // Use a custom initializer to pass required arguments to the ViewModel
    init(buildingID: String, floorID: String, emergencyType: EmergencyType) {
        self.buildingID = buildingID
        self.floorID = floorID
        self.emergencyType = emergencyType
        
        // FIX: Pass required IDs to the ViewModel initializer
        _viewModel = StateObject(wrappedValue: InstructionsListViewModel(
            buildingID: buildingID,
            emergencyTypeID: emergencyType.id!
        ))
    }
    
    var body: some View {
        List {
            Section {
                // FIX: Use the 'id' property of InstructionStep to satisfy ForEach
                ForEach(viewModel.editableSteps) { step in
                    InstructionStepCard(step: step)
                }
                // .onDelete(perform: viewModel.deleteStep) // Re-implement deletion logic if needed
                // .onMove(perform: viewModel.moveStep) // Re-implement move logic if needed
            } header: {
                Text("Steps")
            } footer: {
                Text("You can re-order steps by dragging and dropping.")
            }
        }
        .navigationTitle("\(emergencyType.prettyType) Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // 1. "Add" button
                    Button {
                        isAddingStep = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    // 2. "Edit/Done" button for re-ordering
                    EditButton()
                }
            }
            
            // 3. "Save" button (only appears if changes are made)
            ToolbarItem(placement: .bottomBar) {
                if viewModel.isEditing { // Assuming you set isEditing when changes happen
                    Button("Save Changes") {
                        viewModel.saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        // Sheet for adding a new step
        .sheet(isPresented: $isAddingStep) {
            NavigationStack {
                // Pass the existing ViewModel to the modal view
                CreateInstructionStepView(
                    viewModel: viewModel
                    // Callback to refresh the data after modal closes
                ) {
                    // Optional: trigger post-save refresh logic here
                }
            }
        }
        // Load the steps when the view appears
        .onAppear {
            // Load the instructions from the EmergencyType object into the editable VM
            viewModel.loadInitialInstructions(from: emergencyType.instructions)
        }
    }
}
