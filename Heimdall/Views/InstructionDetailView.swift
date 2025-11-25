//
//  InstructionDetailView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 24/11/25.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
internal import Combine

struct InstructionDetailView: View {
    
    let buildingID: String
    let emergencyTypeID: String

    @State private var selectedFloor: Floor?
    
    // ViewModels must be accessible across the file
    @StateObject private var viewModel: InstructionDetailViewModel
    @StateObject private var editViewModel: InstructionsListViewModel
    
    // FIX: Add state variable for showing the instruction editor
    @State private var isShowingEditSheet = false
    
    init(buildingID: String, emergencyTypeID: String) {
        self.buildingID = buildingID
        self.emergencyTypeID = emergencyTypeID
        
        let dataVM = InstructionDetailViewModel()
        _viewModel = StateObject(wrappedValue: dataVM)
        // FIX: Initializing editViewModel with required IDs
        _editViewModel = StateObject(wrappedValue: InstructionsListViewModel(
            buildingID: buildingID,
            emergencyTypeID: emergencyTypeID
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                floorSelectorSection
                instructionsSection
            }
            .padding()
        }
        .navigationTitle("Instructions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchData(buildingID: buildingID, emergencyTypeID: emergencyTypeID)
        }
        .onChange(of: viewModel.floors) { newFloors in
            if selectedFloor == nil, let first = newFloors.first {
                selectedFloor = first
            }
        }
        .onChange(of: viewModel.emergencyType) { newType in
             editViewModel.loadInitialInstructions(from: newType?.instructions)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // FIX: This button is now fully implemented to show the editor
                    Button {
                        isShowingEditSheet = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                    }
                    
                    // We only show the "Add" button if we are in the editing flow (which is now triggered by the pencil button)
                }
            }
        }
        // FIX: Add the sheet to present the editing interface
        .sheet(isPresented: $isShowingEditSheet) {
            NavigationStack {
                // We pass the editViewModel so the InstructionsListView can read/write the list
                InstructionsListView(
                    buildingID: buildingID,
                    floorID: selectedFloor?.id ?? "", // Best guess floorID if needed by children
                    emergencyType: viewModel.emergencyType!
                )
            }
        }
    }
}

private extension InstructionDetailView {
    var headerSection: some View {
        Text(viewModel.emergencyType?.prettyType ?? "Evacuation Plan")
            .font(.largeTitle.bold())
            .padding(.top, 20)
    }
}

private extension InstructionDetailView {
    var floorSelectorSection: some View {
        Group {
            if viewModel.floors.count > 1 {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Floor Context").font(.headline)
                    
                    Picker("Select Floor", selection: $selectedFloor) {
                        ForEach(viewModel.floors) { floor in
                            Text(floor.name).tag(floor as Floor?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            } else if let floor = viewModel.floors.first {
                Text("Floor: \(floor.name)")
                    .font(.headline)
                    .padding(.vertical)
            }
        }
    }
}

private extension InstructionDetailView {
    var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Evacuation Steps").font(.title2.bold())
            instructionsList
        }
    }
    
    var instructionsList: some View {
        Group {
            // Display instructions from the live edit VM copy
            let steps = editViewModel.editableSteps
            
            if steps.isEmpty {
                Text("No instructions have been defined for this emergency.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(steps) { InstructionStepCard(step: $0) }
                }
                .listStyle(.plain)
                .frame(height: CGFloat(steps.count) * 100 + 50)
            }
        }
    }
}

// FIX: InstructionStepCard is defined here for scope resolution
struct InstructionStepCard: View {
    let step: InstructionStep
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("\(step.step)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.theme)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(step.title).font(.headline)
                    Text(step.description).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
