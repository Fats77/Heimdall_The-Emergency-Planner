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
    @State private var assemblyPoints: [AssemblyPoint] = [] // State to hold points
    @State private var isAddingAssemblyPoint = false // State for modal
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                
                // --- MARK: - Assembly Points Section (Fully Implemented) ---
                VStack(alignment: .leading, spacing: 16) {
                    Text("Assembly Points")
                        .font(.title2.bold())
                    
                    if assemblyPoints.isEmpty {
                        Text("No assembly points set for this emergency type.")
                            .foregroundColor(.secondary)
                    } else {
                        // Use List-style display for deletion capability
                        VStack(spacing: 0) {
                            ForEach(assemblyPoints.indices, id: \.self) { index in
                                PointRow(point: assemblyPoints[index])
                                    .padding(.vertical, 8)
                                    .background(Color(.systemBackground))
                            }
                            .onDelete(perform: deletePoint) // Enable swipe-to-delete
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    
                    Button {
                        isAddingAssemblyPoint = true
                    } label: {
                        Label("Add New Assembly Point", systemImage: "mappin.and.ellipse")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Save Button
                Button(action: {
                    Task {
                        await saveEmergencyType()
                    }
                }) {
                    Text(isLoading ? "Saving..." : "Save Emergency Type")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.23, green: 0.59, blue: 0.59))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding()
            }
        }
        .navigationTitle("New Emergency Plan")
        .background(Color(.systemGray6).ignoresSafeArea())
        .sheet(isPresented: $isAddingAssemblyPoint) {
            NavigationStack {
                // Pass the current array down for modification (Binding)
                AssemblyPointManagerView(
                    points: $assemblyPoints,
                    emergencyType: emergencyType
                )
            }
        }
        .alert("Error", isPresented: $showError, presenting: errorMessage) { message in
            Button("OK") {}
        } message: { message in
            Text(message)
        }
    }
    
    private func deletePoint(offsets: IndexSet) {
        assemblyPoints.remove(atOffsets: offsets)
    }

    func saveEmergencyType() async {
        isLoading = true
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var newType = EmergencyType(
            type: emergencyType,
            scheduleDay: scheduleDay,
            scheduleTime: timeFormatter.string(from: scheduleTime),
            scheduleInterval: scheduleInterval,
            assemblyPoints: assemblyPoints.isEmpty ? nil : assemblyPoints // Save the points array
        )
        
        do {
            let db = Firestore.firestore()
            let docRef = try await db.collection("buildings").document(buildingID)
                                     .collection("floors").document(floorID)
                                     .collection("emergencyTypes")
                                     .addDocument(from: newType)
            
            newType.id = docRef.documentID
            
            onSave(newType)
            isLoading = false
            dismiss()
            
        } catch {
            self.errorMessage = "Error saving emergency type: \(error.localizedDescription)"
            self.showError = true
            isLoading = false
        }
    }
}

// Helper struct for displaying a single assembly point row
struct PointRow: View {
    let point: AssemblyPoint
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
            VStack(alignment: .leading) {
                Text(point.name)
                    .font(.headline)
                Text("Lat: \(point.latitude, specifier: "%.4f"), Lon: \(point.longitude, specifier: "%.4f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
//    CreateEmergencyTypeView()
}
