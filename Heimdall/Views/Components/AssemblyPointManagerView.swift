//
//  AssemblyPointManagerView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 23/11/25.
//

import SwiftUI
import CoreLocation
internal import Combine

// We assume AssemblyPoint and LocationManager are available globally

struct AssemblyPointManagerView: View {
    
    // BINDING: Allows us to modify the points array in the parent view (CreateEmergencyTypeView)
    @Binding var points: [AssemblyPoint]
    let emergencyType: String
    
    @StateObject private var viewModel = AssemblyPointViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            // MARK: - Current Points
            Section(header: Text("Current Points (\(points.count))")) {
                if points.isEmpty {
                    Text("No assembly points defined.")
                        .foregroundColor(.secondary)
                }
                
                // ForEach relies on AssemblyPoint being Identifiable (fixed in Models.swift)
                ForEach(points) { point in
                    PointRow(point: point)
                }
                .onDelete(perform: deletePoint)
            }
            
            // MARK: - Add New Point (Broken into smaller views for compiler)
            Section(header: Text("Add New Point")) {
                VStack(alignment: .leading, spacing: 15) {
                    TextField("Point Name (e.g., Main Parking Lot)", text: $viewModel.newName)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                    
                    // Helper View for Coordinate Inputs
                    coordinateInputs
                    
                    // Helper View for Action Buttons
                    actionButtons
                }
            }
        }
        .navigationTitle("Set Assembly Points")
        .toolbar {
            Button("Done") { dismiss() }
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("Accessing GPS...")
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(10)
                }
            }
        )
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in Button("OK") {} } message: { Text($0) }
    }
    
    private func deletePoint(offsets: IndexSet) {
        points.remove(atOffsets: offsets)
    }
    
    // Helper to separate complex coordinate input fields
    private var coordinateInputs: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coordinates").font(.caption).foregroundColor(.secondary)
            HStack {
                TextField("Latitude", text: $viewModel.newLatString)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Longitude", text: $viewModel.newLonString)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    // Helper to separate action buttons
    private var actionButtons: some View {
        VStack(spacing: 10) {
            // Button to use GPS location (Feature 7)
            Button(action: {
                viewModel.useCurrentLocation()
            }) {
                Label("Set Current Location", systemImage: "location.fill")
                    .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(.bordered)
            
            // Button to add the finalized point
            Button("Add Point to Plan") {
                if let newPoint = viewModel.addPoint() {
                    points.append(newPoint) // Add to the bound array
                    viewModel.resetFields()
                }
            }
            .disabled(!viewModel.canAddPoint || viewModel.isLoading)
            .buttonStyle(.borderedProminent)
        }
    }
}
