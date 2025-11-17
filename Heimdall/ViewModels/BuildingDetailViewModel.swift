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
    @Published var floors: [Floor] = []
    
    // List of *all* emergency plans in this building
    @Published var allEmergencyTypes: [EmergencyType] = []
    
    private var db = Firestore.firestore()
    private var buildingID: String
    private var userID: String?
    
    // Listeners
    private var roleListener: ListenerRegistration?
    private var floorListener: ListenerRegistration?
    private var emergencyTypeListeners: [ListenerRegistration] = []
    
    init(buildingID: String) {
        self.buildingID = buildingID
        self.userID = Auth.auth().currentUser?.uid
    }
    
    func onAppear() {
        checkUserRole()
        fetchFloors()
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
                return
            }
            
            let role = snapshot.data()?["role"] as? String
            self?.isAdmin = (role == "admin")
        }
    }
    
    /// Fetches all floors
    private func fetchFloors() {
        floorListener?.remove()
        let query = db.collection("buildings").document(buildingID).collection("floors")
        
        floorListener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            self?.floors = documents.compactMap { try? $0.data(as: Floor.self) }
            
            // Now, for each floor, fetch its emergency types
            self?.fetchAllEmergencyTypes()
        }
    }
    
    /// Fetches all emergency types for all floors (for the admin panel)
    private func fetchAllEmergencyTypes() {
        // Clear old listeners
        emergencyTypeListeners.forEach { $0.remove() }
        emergencyTypeListeners = []
        
        // This query is a bit more advanced. We use a Collection Group query.
        let query = db.collectionGroup("emergencyTypes")
                      .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: "buildings/\(buildingID)/")
                      .whereField(FieldPath.documentID(), isLessThan: "buildings/\(buildingID)0")
        
        let listener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            self?.allEmergencyTypes = documents.compactMap { try? $0.data(as: EmergencyType.self) }
        }
        emergencyTypeListeners.append(listener)
    }

    deinit {
        roleListener?.remove()
        floorListener?.remove()
        emergencyTypeListeners.forEach { $0.remove() }
    }
}
