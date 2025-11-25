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
    @Published var memberCount: Int = 0
    
    // Tracks the currently active event in this building
    @Published var activeEvent: Event?
    
    private var db = Firestore.firestore()
    private var buildingID: String
    private var userID: String?
    
    // Listeners
    private var roleListener: ListenerRegistration?
    private var floorListener: ListenerRegistration?
    private var eventListener: ListenerRegistration?
    private var memberCountListener: ListenerRegistration?
    private var emergencyTypeListeners: [ListenerRegistration] = []
    
    init(buildingID: String) {
        self.buildingID = buildingID
        self.userID = Auth.auth().currentUser?.uid
    }
    
    func onAppear() {
        checkUserRole()
        fetchFloors()
        fetchMemberCount()
        listenForActiveEvent()
    }
    
    // MARK: - Core Data Fetchers
    
    /// Checks the user's role for this building
    private func checkUserRole() {
        guard let userID = userID else { return }
        
        roleListener?.remove()
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("members").document(userID)
        
        roleListener = docRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self, let snapshot = snapshot, snapshot.exists else {
                self?.isAdmin = false
                self?.isCoordinator = false
                self?.isManager = false
                return
            }
            
            let role = snapshot.data()?["role"] as? String
            
            self.isAdmin = (role == BuildingMember.Role.admin.rawValue)
            self.isCoordinator = (role == BuildingMember.Role.coordinator.rawValue)
            self.isManager = self.isAdmin || self.isCoordinator
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
    
    /// Fetches all floors (COMPLETE)
    func fetchFloors() {
        floorListener?.remove()
        let query = db.collection("buildings").document(buildingID).collection("floors").order(by: "name")
        
        floorListener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            self?.floors = documents.compactMap { doc in
                // Attempt to decode using the global Floor model
                try? doc.data(as: Floor.self)
            }
            // Now, fetch all emergency types associated with these floors
            self?.fetchAllEmergencyTypes()
        }
    }
    
    /// Fetches all emergency types for all floors (FIXED)
    private func fetchAllEmergencyTypes() {
        emergencyTypeListeners.forEach { $0.remove() }
        emergencyTypeListeners = []
        
        let query = db.collectionGroup("emergencyTypes")
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: "buildings/\(buildingID)/")
            // FIX: Corrected Path.documentID() to FieldPath.documentID()
            .whereField(FieldPath.documentID(), isLessThan: "buildings/\(buildingID)0")

        // Correct closure syntax for addSnapshotListener
        let listener = query.addSnapshotListener { [weak self] (snapshot: QuerySnapshot?, error: Error?) in
            
            if let error = error {
                print("Error fetching emergency types: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self?.allEmergencyTypes = documents.compactMap { doc in
                try? doc.data(as: EmergencyType.self)
            }
        }
        emergencyTypeListeners.append(listener)
    }
    
    /// Listens for any active event in this building. (COMPLETE)
    private func listenForActiveEvent() {
        eventListener?.remove()
        let query = db.collection("buildings").document(buildingID)
                      .collection("events")
                      .whereField("status", isEqualTo: Event.Status.active.rawValue)
                      .limit(to: 1)
        
        eventListener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let doc = snapshot?.documents.first else {
                self?.activeEvent = nil
                return
            }
            self?.activeEvent = try? doc.data(as: Event.self)
        }
    }
    
    // MARK: - Actions
    
    /// Implements Feature 5: Delete Floor (COMPLETE)
    func deleteFloor(at offsets: IndexSet) {
        guard isAdmin else { return }
        
        let floorsToDelete = offsets.map { self.floors[$0] }
        
        for floor in floorsToDelete {
            guard let floorID = floor.id else { continue }
            
            db.collection("buildings").document(buildingID).collection("floors").document(floorID).delete { error in
                if let error = error {
                    print("Error deleting floor: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Implements Feature 4/9: Stops the active emergency alert. (COMPLETE)
    func stopActiveEvent() async -> Bool {
        guard isAdmin || isCoordinator, let eventID = activeEvent?.id else {
            print("Error: User is not manager or no active event found.")
            return false
        }
        
        do {
            let docRef = db.collection("buildings").document(buildingID)
                          .collection("events").document(eventID)
            
            try await docRef.updateData([
                "status": Event.Status.completed.rawValue,
                "endTime": FieldValue.serverTimestamp()
            ])
            
            // Clear local tracking state
            self.activeEvent = nil
            return true
            
        } catch {
            print("Error stopping event \(eventID): \(error.localizedDescription)")
            // TODO: Add error handling for UI
            return false
        }
    }
    
    /// Deletes the entire building plan (Feature 1)
    func deleteBuilding(building: Building) {
        guard isAdmin, let buildingID = building.id else { return }
        // Note: Full cleanup of subcollections must be handled server-side (Cloud Function).
        db.collection("buildings").document(buildingID).delete() { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Building successfully deleted! (Subcollections pending cleanup function)")
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
            
            print("Successfully left plan \(buildingID).")
            
        } catch {
            print("Error leaving plan: \(error.localizedDescription)")
        }
    }

    deinit {
        roleListener?.remove()
        floorListener?.remove()
        memberCountListener?.remove()
        eventListener?.remove()
        emergencyTypeListeners.forEach { $0.remove() }
    }
}
