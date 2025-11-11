//
//  JoinOrCreateView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 10/11/25.
//


import SwiftUI

struct JoinOrCreateView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var inviteCode: String = ""
    @State private var newBuildingName: String = ""
    @State private var newBuildingDesc: String = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var showCreateForm = false

    var body: some View {
        VStack(spacing: 20) {
            
            if firestoreManager.isLoading {
                ProgressView()
                Text("Please wait...")
            } else if showCreateForm {
                createBuildingForm
            } else {
                joinBuildingForm
            }
        }
        .padding()
        .navigationTitle("Get Started")
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // View for joining a building
    private var joinBuildingForm: some View {
        VStack(spacing: 20) {
            Text("Join an Existing Building")
                .font(.headline)
            
            TextField("Enter Invite Code (e.g., A9B2Z7)", text: $inviteCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
            
            Button(action: handleJoin) {
                Text("Join Building")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Divider()
            
            Button("Or, Create a New Building") {
                showCreateForm = true
            }
        }
    }
    
    // View for creating a building
    private var createBuildingForm: some View {
        VStack(spacing: 20) {
            Text("Create a New Building")
                .font(.headline)
            
            TextField("Building Name (e.g., Main Office)", text: $newBuildingName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Building Description", text: $newBuildingDesc)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: handleCreate) {
                Text("Create Building")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(newBuildingName.isEmpty)
            
            Divider()
            
            Button("Back to Join") {
                showCreateForm = false
            }
        }
    }
    
    // --- ACTIONS ---
    
    func handleJoin() {
        guard !inviteCode.isEmpty else {
            errorMessage = "Please enter an invite code."
            showError = true
            return
        }
        
        Task {
            let success = await firestoreManager.joinBuilding(inviteCode: inviteCode)
            if !success {
                errorMessage = "Invalid invite code or an error occurred."
                showError = true
            }
        }
    }
    
    func handleCreate() {
        guard !newBuildingName.isEmpty, let currentUser = authManager.currentUser else {
            errorMessage = "Please enter a building name."
            showError = true
            return
        }
        
        Task {
            let success = await firestoreManager.createBuilding(
                name: newBuildingName,
                description: newBuildingDesc,
                creator: currentUser
            )
            if !success {
                errorMessage = "Could not create building. Please try again."
                showError = true
            }
        }
    }
}

#Preview{
    JoinOrCreateView()
}
