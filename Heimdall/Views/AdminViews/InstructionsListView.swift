//
//  InstructionsListView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI

struct InstructionsListView: View {
    // Pass in the IDs of the parent documents
    let buildingID: String
    let floorID: String
    let emergencyType: EmergencyType
    
    @StateObject private var viewModel = InstructionsListViewModel()
    @State private var isAddingStep = false
    
    var body: some View {
        List {
            Section {
                // Use ForEach to get .onDelete and .onMove
                ForEach(viewModel.instructionSteps) { step in
                    HStack {
                        // Display the step number
                        Text("\(step.step)")
                            .font(.title.bold())
                            .foregroundColor(.accentColor)
                            .padding(.trailing, 8)
                        
                        VStack(alignment: .leading) {
                            Text(step.title)
                                .font(.headline)
                            Text(step.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteStep)
                .onMove(perform: viewModel.moveStep)
            } header: {
                Text("Steps")
            } footer: {
                Text("You can re-order steps by dragging and dropping.")
            }
        }
        .navigationTitle("\(emergencyType.prettyType) Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 1. "Add" button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddingStep = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            // 2. "Edit/Done" button for re-ordering
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            
            // 3. "Save" button (only appears if changes are made)
            ToolbarItem(placement: .bottomBar) {
                if viewModel.hasChanges {
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
                CreateInstructionStepView(
                    buildingID: buildingID
                ) { newStep in
                    // This is the callback
                    viewModel.addStep(newStep)
                }
            }
        }
        // Load the steps when the view appears
        .onAppear {
            viewModel.fetchInstructions(
                buildingID: buildingID,
                floorID: floorID,
                emergencyTypeID: emergencyType.id!
            )
        }
    }
}
