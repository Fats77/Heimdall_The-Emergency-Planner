//
//  BuildingDetailView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 11/11/25.
//


import SwiftUI
import FirebaseFirestore

struct BuildingDetailView: View {
    let building: Building
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreManager: FirestoreManager
        
    // --- CHANGE THIS ---
    @State private var userRole: BuildingMember.Role = .member // Default to member
    
    // This state var will show/hide the "Create Drill" form
    @State private var isShowingCreateDrillSheet = false

    var body: some View {
        TabView {
            // --- TAB 1: Drills ---
            DrillsTabView(building: building)
                .tabItem {
                    Image(systemName: "timer.square")
                    Text("Drills")
                }
            
            // --- TAB 2: Instructions ---
            InstructionsTabView() // This one doesn't need data (yet)
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Instructions")
                }
            
            // --- TAB 3: Members ---
            MembersTabView(building: building, userRole: userRole)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Members")
                }
                // --- PASS THE ENVIRONMENT OBJECT ---
                .environmentObject(firestoreManager)
        }
        .navigationTitle(building.name)
        .toolbar {
            // Only show the "Create Drill" button if they are an Admin
            if userRole == .admin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingCreateDrillSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingCreateDrillSheet) {
            // This is the new View we are about to create
            CreateDrillView(building: building)
        }
    }
}

// --- Placeholder Tab Views (You can build these out next) ---

struct DrillsTabView: View {
    let building: Building
    
    // This will hold the drills we fetch from Firestore
    @State var drills: [Drill] = []
    
    // We'll use this to listen for changes
    var db = Firestore.firestore()
    
    var body: some View {
        List(drills) { drill in
            VStack(alignment: .leading) {
                Text(drill.emergencyType.rawValue)
                    .font(.headline)
                Text("Scheduled: \(drill.interval.rawValue)")
                    .font(.subheadline)
                Text("\(drill.instructions.count) instructions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Drills") // This might be redundant, but is good practice
        .onAppear {
            // This is the most important part
            // We'll listen for real-time updates
            listenForDrills()
        }
    }
    
    func listenForDrills() {
        guard let buildingId = building.id else { return }
        
        db.collection("buildings").document(buildingId)
          .collection("drills")
          .addSnapshotListener { (querySnapshot, error) in
              
              guard let snapshot = querySnapshot else {
                  print("Error fetching drills: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }
              
              // This line is amazing. It automatically maps the
              // Firestore documents to our Swift 'Drill' struct.
              self.drills = snapshot.documents.compactMap { document in
                  try? document.data(as: Drill.self)
              }
              
              print("Fetched \(drills.count) drills")
          }
    }
}

struct InstructionsTabView: View {
    var body: some View {
        Text("List of all instructions for all drills goes here.")
            .navigationTitle("Instructions")
    }
}

struct MembersTabView: View {
    // We need the building ID to know *which* members to fetch
    let building: Building
    // We need the user's role to show/hide the admin controls
    let userRole: BuildingMember.Role
    
    // This will hold the list of members we fetch
    @State private var members: [BuildingMember] = []
    
    // We need the FirestoreManager to call our new functions
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    var body: some View {
        List(members) { member in
            HStack {
                VStack(alignment: .leading) {
                    Text(member.displayName)
                        .font(.headline)
                    Text(member.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Show the user's role
                if userRole == .admin {
                    // If we are an admin, show a Picker to change roles
                    Picker("Role", selection: binding(for: member)) {
                        ForEach(BuildingMember.Role.allCases, id: \.self) { role in
                            Text(role.rawValue.capitalized).tag(role)
                        }
                    }
                    .pickerStyle(.segmented) // A nice compact style
                    .frame(width: 200)
                } else {
                    // If we are not an admin, just show their role as text
                    Text(member.role.rawValue.capitalized)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 5)
        }
        .onAppear {
            // When the view appears, fetch the members
            loadMembers()
        }
    }
    
    func loadMembers() {
        guard let buildingId = building.id else { return }
        Task {
            self.members = await firestoreManager.fetchMembers(forBuildingId: buildingId)
        }
    }
    
    // This is a helper function to make the Picker work.
    // It finds the member in our @State array and creates a
    // binding, so when the Picker changes, we can save the data.
    private func binding(for member: BuildingMember) -> Binding<BuildingMember.Role> {
        // Find the index of the member in our array
        guard let index = members.firstIndex(where: { $0.id == member.id }) else {
            // This should never happen, but we need a fallback
            return .constant(member.role)
        }
        
        // Return a binding to that specific member's role
        return $members[index].role.onChange { newRole in
            // When the role changes, call our save function
            saveRoleChange(for: member, newRole: newRole)
        }
    }
    
    // This is the function that saves the new role to Firestore
    func saveRoleChange(for member: BuildingMember, newRole: BuildingMember.Role) {
        guard let buildingId = building.id, let userId = member.id else { return }
        
        Task {
            let success = await firestoreManager.updateMemberRole(
                userId: userId,
                buildingId: buildingId,
                newRole: newRole
            )
            
            if success {
                print("Successfully updated role for \(member.displayName)")
            } else {
                print("Failed to update role for \(member.displayName)")
                // TODO: Show an error and reset the picker
                loadMembers() // Re-fetch data to reset the UI
            }
        }
    }
}

// This is a small helper to trigger an action when a Binding changes
// Add this extension to the bottom of your MembersTabView.swift file
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
