//
//  AssemblyPointManagerView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 23/11/25.
//

import SwiftUI
import CoreLocation

// We assume LocationManager and AssemblyPoint are globally available

struct AssemblyPointManagerView: View {
    
    // BINDING: Allows us to modify the points array in the parent view
    @Binding var points: [AssemblyPoint]
    let emergencyType: String
    
    @StateObject private var viewModel = AssemblyPointViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            // MARK: - Current Points
            Section(header: Text("Points for \(emergencyType.capitalized)")) {
                if points.isEmpty {
                    Text("No assembly points defined.")
                        .foregroundColor(.secondary)
                }
                
                // This ForEach will now compile cleanly because AssemblyPoint is Identifiable
                ForEach(points) { point in
                    PointRow(point: point)
                }
                .onDelete(perform: deletePoint)
            }
            
            // MARK: - Add New Point
            Section(header: Text("Add New Point")) {
                TextField("Point Name (e.g., Main Parking Lot)", text: $viewModel.newName)
                
                HStack {
                    TextField("Latitude", text: $viewModel.newLatString)
                        .keyboardType(.decimalPad)
                    Divider()
                    TextField("Longitude", text: $viewModel.newLonString)
                        .keyboardType(.decimalPad)
                }
                
                // Add button that uses the current location
                Button("Use My Current Location") {
                    viewModel.useCurrentLocation()
                }
                
                Button("Add Point") {
                    if let newPoint = viewModel.addPoint() {
                        points.append(newPoint) // Add to the bound array
                        viewModel.resetFields()
                    }
                }
                .disabled(!viewModel.canAddPoint)
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Set Assembly Points")
        .toolbar {
            Button("Done") { dismiss() }
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in Button("OK") {} } message: { Text($0) }
    }
    
    private func deletePoint(offsets: IndexSet) {
        points.remove(atOffsets: offsets)
    }
}
