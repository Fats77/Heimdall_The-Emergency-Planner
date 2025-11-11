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
            InstructionsTabView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Instructions")
                }
            
            // --- TAB 3: Members ---
            MembersTabView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Members")
                }
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
    var body: some View {
        Text("List of all members in this building goes here.")
            .navigationTitle("Members")
    }
}
