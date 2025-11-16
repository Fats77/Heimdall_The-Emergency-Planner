//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//  FIXED by Gemini on 11/11/25
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showAddContactSheet = false
    @State private var newContactName: String = ""
    @State private var newContactPhone: String = ""
    
    let columns: [GridItem] = [
        GridItem(.flexible()) , GridItem(.flexible()) ,GridItem(.flexible())
    ]
    
    let contactColumns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                //MARK: Header Overview
                HStack{
                    Text("Hello, \(authManager.currentUser?.displayName ?? "User")")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                }
                .padding(.horizontal)
                .padding(.vertical,5)
                
                //MARK: Drill Plans Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        // --- 5. FIX: Renamed section for clarity ---
                        Text("Your Buildings")
                            .font(.title3.bold())
                            .foregroundColor(Color.primary)
                        Spacer()
                        
                        // --- 6. FIX: This "Add New" link goes to Join/Create ---
                        NavigationLink(destination: JoinOrCreateView()) {
                            // --- REPLACED CustomButtonView with standard Label ---
                            Label("Add New", systemImage: "plus")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .foregroundColor(.white)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                    
                    //MARK: Drill Cards
                    // --- 7. FIX: Loop over real buildings ---
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(firestoreManager.userBuildings) { building in
                            // --- 8. FIX: The link to detail goes on the card ---
                            NavigationLink(destination: BuildingDetailView(building: building).environmentObject(firestoreManager)) {
                                Text(building.name) // Use the building's name
                                    .lineLimit(2)
                                    .padding()
                                    .frame(width: 100, height: 150)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(0.8), Color(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .foregroundStyle(Color.primary)
                                    .cornerRadius(12)
                                    .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                            }
                        }
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                
                //MARK: Emergency Contacts
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone")
                            .imageScale(.large)
                        Text("Personal Emergency Contact")
                            .font(.title3.bold())
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    
                    //MARK: Emergency Contact List
                    LazyVGrid(columns: contactColumns, alignment: .leading, spacing: 10) {
                        // --- 9. FIX: Loop over real contacts ---
                        ForEach(authManager.currentUser?.emergencyContacts ?? [], id: \.phone) { contact in
                            Text(contact.name)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(Color.primary)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        
                        Button {
                            showAddContactSheet = true
                        }
                        label: {
                            HStack() {
                                Text("Add New")
                                Image(systemName: "plus")
                            }
                        }
                        .accessibilityLabel(Text("Add New Emergency Contact"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        // --- REPLACED PrimaryGradientView with standard color ---
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                //MARK: History Section Header
                VStack(alignment: .leading, spacing: 12) {
                    // ... (History section remains as placeholder)
                    HStack(spacing: 10) {
                        Image(systemName: "clock")
                            .imageScale(.large)
                        Text("History")
                            .font(.title3.bold())
                    }
                    .padding(.leading, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    //MARK: History List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alert history will appear here.")
                            .padding()
                        // ForEach(1...6, id: \.self) { index in ... }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            }
            .background(Color(.systemGroupedBackground))
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            
            // --- 10. FIX: Use .navigationDestination, not .navigationBarBackButtonHidden ---
            // This view is now the root, so it shouldn't hide the back button
            // .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $showAddContactSheet) {
            VStack(spacing: 20) {
                Text("Add Emergency Contact")
                    .font(.title2.bold())
                    .padding(.top)
                
                // --- 11. FIX: Connect TextFields to @State ---
                TextField("Name", text: $newContactName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Phone Number", text: $newContactPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                Button("Save Contact") {
                    // --- 12. FIX: Call save function ---
                    saveContact()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                // --- REPLACED PrimaryGradientView with standard color ---
                .background(Color.accentColor)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // --- 13. ADD: Function to save the contact ---
    func saveContact() {
        guard !newContactName.isEmpty,
              !newContactPhone.isEmpty,
              let uid = authManager.userSession?.uid else {
            print("Error: Fields are empty or user is not logged in.")
            return
        }
        
        let newContact = EmergencyContact(name: newContactName, phone: newContactPhone)
        
        Task {
            let success = await firestoreManager.addEmergencyContact(newContact, for: uid)
            if success {
                // Update the local user model
                authManager.currentUser?.emergencyContacts?.append(newContact)
                
                // Clear fields and dismiss sheet
                newContactName = ""
                newContactPhone = ""
                showAddContactSheet = false
            } else {
                // TODO: Show an error alert to the user
                print("Error: Failed to save contact to Firestore.")
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager()) // Add mock managers for preview
        .environmentObject(FirestoreManager())
}
