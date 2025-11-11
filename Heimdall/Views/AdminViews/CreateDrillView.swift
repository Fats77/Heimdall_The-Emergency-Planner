//
//  CreateDrillView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 11/11/25.
//


import SwiftUI
import FirebaseFirestore

struct CreateDrillView: View {
    let building: Building
    
    // Get the presentation environment to dismiss the sheet
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    // --- Drill Properties ---
    @State private var emergencyType: Drill.EmergencyType = .fire
    @State private var interval: Drill.DrillInterval = .monthly
    @State private var scheduleDay: Int = 1
    @State private var scheduleTime: Date = Date()
    
    // --- Instruction Properties ---
    @State private var instructions: [Instruction] = []
    
    // --- State for the Instruction component ---
    @State private var instructionTitle: String = ""
    @State private var instructionDesc: String = ""

    var body: some View {
        NavigationView {
            Form {
                // --- Section 1: Drill Details ---
                Section(header: Text("Drill Details")) {
                    // Emergency Type Picker
                    Picker("Emergency Type", selection: $emergencyType) {
                        ForEach(Drill.EmergencyType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    // Interval Picker
                    Picker("Interval", selection: $interval) {
                        ForEach(Drill.DrillInterval.allCases) { interval in
                            Text(interval.rawValue).tag(interval)
                        }
                    }
                    
                    // Schedule Day (your custom input)
                    Stepper("Day of Month: \(scheduleDay)", value: $scheduleDay, in: 1...28)
                    
                    // Schedule Time (your custom time picker)
                    DatePicker("Schedule Time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                }
                
                // --- Section 2: Instructions (1-to-Many) ---
                Section(header: Text("Instructions")) {
                    // List of instructions already added
                    ForEach(instructions) { instruction in
                        VStack(alignment: .leading) {
                            Text(instruction.title).font(.headline)
                            Text(instruction.description).font(.caption)
                        }
                    }
                    .onDelete(perform: deleteInstruction)
                    
                    // --- Your "Create Instruction" Component ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add New Instruction")
                            .font(.headline)
                        TextField("Title (e.g., 'Evacuate')", text: $instructionTitle)
                        TextField("Description (e.g., 'Use nearest exit')", text: $instructionDesc)
                        
                        // TODO: Add your Image picker UI here
                        
                        Button(action: addInstruction) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Instruction")
                            }
                        }
                        .disabled(instructionTitle.isEmpty)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("New Drill Plan")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    handleSave()
                }
            )
        }
    }
    
    func addInstruction() {
        guard !instructionTitle.isEmpty else { return }
        
        let newInstruction = Instruction(
            id: UUID(),
            title: instructionTitle,
            description: instructionDesc
            // imageURL: (from your image picker)
        )
        
        instructions.append(newInstruction)
        
        // Clear the form
        instructionTitle = ""
        instructionDesc = ""
    }
    
    func deleteInstruction(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
    }
    
    func handleSave() {
            // 1. Format the time
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: scheduleTime)
            
            // 2. Create the new Drill object
            let newDrill = Drill(
                emergencyType: emergencyType,
                interval: interval,
                scheduleDay: scheduleDay,
                scheduleTime: timeString,
                instructions: instructions
            )
            
            // 3. --- THIS IS THE NEW PART ---
            // Get the building ID
            guard let buildingId = building.id else {
                print("Error: Missing building ID")
                presentationMode.wrappedValue.dismiss()
                return
            }
            
            Task {
                // 4. Call the FirestoreManager to save
                let success = await firestoreManager.saveDrill(newDrill, forBuildingId: buildingId)
                
                if success {
                    print("Successfully saved drill!")
                    // TODO: We should tell the previous screen to refresh
                } else {
                    print("Failed to save drill.")
                    // TODO: Show an error alert to the user
                }
            }
            
            // 5. Dismiss the sheet
            presentationMode.wrappedValue.dismiss()
        }
}
