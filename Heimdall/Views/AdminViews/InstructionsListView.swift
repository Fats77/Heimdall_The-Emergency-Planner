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
    @State private var isEditingStep: InstructionStep? = nil
    
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
                // FIX: Added swipe-to-delete and long-press-to-move capabilities
                ForEach(viewModel.editableSteps) { step in
                    InstructionStepCard(step: step)
                        // Tap the card to edit
                        .onTapGesture {
                            isEditingStep = step
                        }
                }
                // FIX: Use closures to pass the index set/int to the ViewModel functions
                .onDelete { offsets in
                    viewModel.deleteStep(at: offsets)
                }
                .onMove { source, destination in
                    viewModel.moveStep(from: source, to: destination)
                }
            } header: {
                Text("Steps")
            } footer: {
                Text("Tap 'Edit' to reorder/delete steps. Tap a step to edit details.")
            }
        }
        .navigationTitle("\(emergencyType.prettyType) Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // 1. "Add" button
                    Button {
                        // FIX: Set the state variable to true to show the modal
                        isAddingStep = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    // 2. "Edit/Done" button for re-ordering
                    EditButton()
                }
            }
            
            // 3. "Save" button
            ToolbarItem(placement: .bottomBar) {
                // NOTE: This check ensures the Save button only appears if the user has edited/reordered the list.
                if !viewModel.editableSteps.elementsEqual(emergencyType.instructions ?? [], by: { $0.id == $1.id }) {
                    Button("Save Changes") {
                        viewModel.saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                } else if viewModel.isLoading {
                     ProgressView()
                }
            }
        }
        // Sheet for adding a new step
        .sheet(isPresented: $isAddingStep) {
            NavigationStack {
                // Pass the existing ViewModel to the modal view for creation
                CreateInstructionStepView(
                    viewModel: viewModel
                ) {
                    // Refresh callback
                }
            }
        }
        // Sheet for editing an existing step
        .sheet(item: $isEditingStep) { stepToEdit in
            NavigationStack {
                CreateInstructionStepView(
                    viewModel: viewModel,
                    editingStep: stepToEdit
                ) {
                    // Refresh callback
                }
            }
        }
        .onAppear {
            // Load the instructions from the EmergencyType object into the editable VM
            viewModel.loadInitialInstructions(from: emergencyType.instructions)
        }
    }
}
