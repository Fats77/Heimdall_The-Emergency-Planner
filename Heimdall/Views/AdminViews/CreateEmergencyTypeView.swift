//
//  CreateEmergencyTypeView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import FirebaseFirestore

struct CreateEmergencyTypeView: View {
    
    // These IDs will be passed in from the previous view (e.g., FloorDetailView)
    let buildingID: String
    let floorID: String
    var onSave: (EmergencyType) -> Void

    @Environment(\.dismiss) var dismiss
    // States for our data model
    @State private var emergencyType = "fire" // Default to a valid type
    @State private var scheduleInterval = "every_month"
    @State private var scheduleDay = 1
    @State private var scheduleTime = Date()
    
    // Picker data
    let emergencyData = [
        ("Fire", "fire"),
        ("Earthquake", "earthquake"),
        ("Tsunami", "tsunami")
    ]
    
    let intervalData = [
        ("Every Month", "every_month"),
        ("Twice a Year", "twice_a_year"),
        ("Thrice a Year", "thrice_a_year"),
        ("Every Year", "every_year")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Emergency Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emergency Type")
                        .font(.title2.bold())
                    
                    Picker("Pick Emergency", selection: $emergencyType) {
                        ForEach(emergencyData, id: \.1) { (name, tag) in
                            Text(name).tag(tag)
                        }
                    }
                    .pickerStyle(.segmented)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                .padding()
                
                // MARK: - Schedule
                VStack(alignment: .leading, spacing: 16) {
                    Text("Schedule Drill")
                        .font(.title2.bold())
                    
                    // Interval Picker
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Interval").font(.headline)
                        Picker("Pick Duration", selection: $scheduleInterval) {
                            ForEach(intervalData, id: \.1) { (name, tag) in
                                Text(name).tag(tag)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Day Picker
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Day of Month").font(.headline)
                        Stepper("Day: \(scheduleDay)", value: $scheduleDay, in: 1...30)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Time Picker
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Time (24-hr)").font(.headline)
                        DatePicker("Select Time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                // MARK: - Save Button
                Button(action: {
                    Task {
                        await saveEmergencyType()
                    }
                }) {
                    Text("Save Emergency Type")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.23, green: 0.59, blue: 0.59))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle("New Emergency Plan")
        .background(Color(.systemGray6).ignoresSafeArea())
    }
    
    func saveEmergencyType() async {
        // TODO: Add 'isLoading' state

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        var newType = EmergencyType(
            type: emergencyType,
            scheduleDay: scheduleDay,
            scheduleTime: timeFormatter.string(from: scheduleTime),
            scheduleInterval: scheduleInterval
        )

        do {
            let db = Firestore.firestore()
            let docRef = try await db.collection("buildings").document(buildingID)
                                     .collection("floors").document(floorID)
                                     .collection("emergencyTypes")
                                     .addDocument(from: newType)

            // Get the ID assigned by Firestore and add it to our model
            newType.id = docRef.documentID

            // Call the callback to update the UI
            onSave(newType)
            dismiss() // Close the sheet

        } catch {
            print("Error saving emergency type: \(error.localizedDescription)")
            // TODO: Show an alert to the user
        }
    }
}

#Preview {
//    CreateEmergencyTypeView()
}
