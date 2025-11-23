//
//  BuildingDetailViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
internal import Combine

@MainActor
class BuildingDetailViewModel: ObservableObject {
    
    @Published var isAdmin = false
    @Published var isCoordinator = false
    @Published var isManager = false // true if isAdmin OR isCoordinator
    @Published var floors: [Floor] = []
    @Published var allEmergencyTypes: [EmergencyType] = []
    @Published var memberCount: Int = 0 // New property
    
    private var db = Firestore.firestore()
    private var buildingID: String
    private var userID: String?
    
    // Listeners
    private var roleListener: ListenerRegistration?
    private var floorListener: ListenerRegistration?
    private var emergencyTypeListeners: [ListenerRegistration] = []
    private var memberCountListener: ListenerRegistration? // New Listener
    
    init(buildingID: String) {
        self.buildingID = buildingID
        self.userID = Auth.auth().currentUser?.uid
    }
    
    func onAppear() {
        checkUserRole()
        fetchFloors()
        fetchMemberCount() // New call
    }
    
    /// Checks the user's role for this building
    private func checkUserRole() {
        guard let userID = userID else { return }
        
        roleListener?.remove()
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("members").document(userID)
        
        roleListener = docRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists else {
                self?.isAdmin = false
                self?.isCoordinator = false
                self?.isManager = false
                return
            }
            
            let role = snapshot.data()?["role"] as? String
            self?.isAdmin = (role == BuildingMember.Role.admin.rawValue)
            self?.isCoordinator = (role == BuildingMember.Role.coordinator.rawValue)
            self?.isManager = (self?.isAdmin ?? false) || (self?.isCoordinator ?? false)
        }
    }
    
    /// Fetches the count of members (Feature 2)
    private func fetchMemberCount() {
        memberCountListener?.remove()
        let query = db.collection("buildings").document(buildingID).collection("members")
        
        memberCountListener = query.addSnapshotListener { [weak self] (snapshot, error) in
            self?.memberCount = snapshot?.documents.count ?? 0
        }
    }
    
    /// Fetches all floors
    func fetchFloors() { // Made public so it can be called from the sheet completion
        floorListener?.remove()
        let query = db.collection("buildings").document(buildingID).collection("floors")
        
        floorListener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            self?.floors = documents.compactMap { try? $0.data(as: Floor.self) }
            
            // Now, for each floor, fetch its emergency types
            self?.fetchAllEmergencyTypes()
        }
    }
    
    /// Fetches all emergency types for all floors
    private func fetchAllEmergencyTypes() {
        // Clear old listeners
        emergencyTypeListeners.forEach { $0.remove() }
        emergencyTypeListeners = []
        
        // Use a collection group query to fetch all related emergency types
        let query = db.collectionGroup("emergencyTypes")
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: "buildings/\(buildingID)/")
            .whereField(FieldPath.documentID(), isLessThan: "buildings/\(buildingID)0")

        let listener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            self?.allEmergencyTypes = documents.compactMap { try? $0.data(as: EmergencyType.self) }
        }
        emergencyTypeListeners.append(listener)
    }
    
    /// Deletes the entire building plan (Feature 1)
    func deleteBuilding(building: Building) { // FIX: Using global Building
        guard isAdmin, let buildingID = building.id else { return }
        
        // Note: For full cleanup, you need a Cloud Function to delete subcollections (floors, members, events, etc.)
        // Firestore won't delete subcollections automatically.
        db.collection("buildings").document(buildingID).delete() { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Building successfully deleted! (Subcollections pending cleanup function)")
                // After successful deletion, the user should be navigated home.
            }
        }
    }
    
    /// Implements Feature 7: User leaves a building
    func leavePlan() async {
        guard let userID = userID else { return }
        
        do {
            // 1. Delete the member document from the building's subcollection
            try await db.collection("buildings").document(buildingID)
                .collection("members").document(userID).delete()
            
            // 2. Remove the building ID from the user's joinedBuildings array
            try await db.collection("users").document(userID).updateData([
                "joinedBuildings": FieldValue.arrayRemove([buildingID])
            ])
            
            // Note: The UI will automatically navigate away (back to HomeView)
            // once the list in HomeView detects this building ID is removed
            // from the user's document via the stream listener.
            print("Successfully left plan \(buildingID).")
            
        } catch {
            print("Error leaving plan: \(error.localizedDescription)")
            // TODO: Display an error alert
        }
    }

    deinit {
        roleListener?.remove()
        floorListener?.remove()
        memberCountListener?.remove()
        emergencyTypeListeners.forEach { $0.remove() }
    }
}
