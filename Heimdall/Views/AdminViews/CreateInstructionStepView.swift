//
//  CreateInstructionStepView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import SwiftUI
import PhotosUI

struct CreateInstructionStepView: View {
    
    let buildingID: String
    var onSave: (InstructionStep) -> Void
    
    @StateObject private var viewModel = CreateInstructionStepViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("Step Details") {
                TextField("Title (e.g., 'Stay Calm')", text: $viewModel.title)
                
                // Use TextEditor for multi-line description
                ZStack(alignment: .topLeading) {
                    if viewModel.description.isEmpty {
                        Text("Description...")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 150)
                }
            }
            
            Section("Optional Image") {
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else {
                        Label("Select Image", systemImage: "photo")
                    }
                }
            }
        }
        .navigationTitle("Add New Step")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveStep()
                }
                .disabled(viewModel.title.isEmpty || viewModel.isLoading)
            }
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
            }
        }
    }
    
    func saveStep() {
        Task {
            let newStep = await viewModel.save(buildingID: buildingID)
            if let newStep = newStep {
                onSave(newStep)
                dismiss()
            }
        }
    }
}