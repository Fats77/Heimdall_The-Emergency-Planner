//
//  CreateInstructionStepView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//
import SwiftUI
import PhotosUI
import Kingfisher

struct CreateInstructionStepView: View {
    
    @ObservedObject var viewModel: InstructionsListViewModel
    var editingStep: InstructionStep? = nil
    var onSave: () -> Void // Callback to refresh parent data view
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var currentImageURL: URL? // For existing photo
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    @Environment(\.dismiss) var dismiss
    
    var isEditing: Bool { editingStep != nil }
    
    init(viewModel: InstructionsListViewModel, editingStep: InstructionStep? = nil, onSave: @escaping () -> Void) {
        self.viewModel = viewModel
        self.editingStep = editingStep
        self.onSave = onSave
        
        // Pre-populate fields if editing
        if let step = editingStep {
            _title = State(initialValue: step.title)
            _description = State(initialValue: step.description)
            if let urlString = step.imageURL, let url = URL(string: urlString) {
                _currentImageURL = State(initialValue: url)
            }
        }
    }
    
    var body: some View {
        Form {
            Section("Step Details") {
                TextField("Title (e.g., 'Stay Calm')", text: $title)
                
                // Use TextEditor for multi-line description
                TextEditor(text: $description)
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)
                    .overlay(
                        Group {
                            if description.isEmpty {
                                Text("Description...")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }, alignment: .topLeading
                    )
            }
            
            Section("Optional Image") {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable().scaledToFit().frame(height: 150).cornerRadius(10)
                        } else if let url = currentImageURL {
                            KFImage(url).resizable().scaledToFit().frame(height: 150).cornerRadius(10)
                        } else {
                            Label("Select Image", systemImage: "photo").frame(height: 50)
                        }
                    }
                }
                .onChange(of: selectedPhotoItem) { item in
                    Task { await loadImage(from: item) }
                }
                
                if currentImageURL != nil || selectedImage != nil {
                    Button("Remove Image", role: .destructive) {
                        currentImageURL = nil
                        selectedImage = nil
                        selectedPhotoItem = nil
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Step \(editingStep?.step ?? 0)" : "Add New Step")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Update" : "Save") {
                    saveStep()
                }
                .disabled(title.isEmpty || viewModel.isLoading)
            }
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(1.5)
            }
        }
    }
    
    // MARK: - Logic
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            self.selectedImage = UIImage(data: data)
            self.currentImageURL = nil // Clear old URL if a new image is selected
        }
    }
    
    private func saveStep() {
        // Start loading state
        viewModel.isLoading = true
        
        // FIX: Extract buildingID explicitly by value *before* the Task begins.
        // This fully resolves the ownership/dynamicMember subscripting confusion.
        let currentBuildingID = viewModel.buildingID
        
        Task {
            // 1. Upload new image if necessary
            var finalImageURL = currentImageURL?.absoluteString
            if let image = selectedImage {
                // Now, call uploadPhoto using the safe, local currentBuildingID variable.
                finalImageURL = await viewModel.uploadPhoto(image: image, for: currentBuildingID)
            } else if currentImageURL == nil {
                finalImageURL = nil
            }
            
            // 2. Prepare the final step object
            let newStep = InstructionStep(
                id: editingStep?.id ?? UUID().uuidString,
                step: editingStep?.step ?? viewModel.editableSteps.count + 1, // Use existing step or calculate new
                title: title,
                description: description,
                imageURL: finalImageURL
            )
            
            // 3. Delegate saving to the ViewModel
            if isEditing {
                viewModel.updateExistingStep(newStep)
            } else {
                viewModel.addNewStep(newStep)
            }
            
            // 4. Trigger Save Changes in VM
            viewModel.saveChanges()
            
            onSave() // Call parent refresh
            dismiss()
        }
    }
}
