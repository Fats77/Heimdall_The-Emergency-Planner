//
//  FloorDetailViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import FirebaseFirestore
internal import Combine
import FirebaseAuth

@MainActor
class FloorDetailViewModel: ObservableObject {
    @Published var emergencyTypes: [EmergencyType] = []
    @Published var isAdmin = false
    @Published var isCoordinator = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var roleListener: ListenerRegistration?
    
    func fetchData(buildingID: String, floorID: String) {
        checkUserRole(buildingID: buildingID)
        fetchEmergencyTypes(buildingID: buildingID, floorID: floorID)
    }
    
    private func checkUserRole(buildingID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        roleListener?.remove()
        db.collection("buildings").document(buildingID).collection("members").document(userID)
            .addSnapshotListener { [weak self] snapshot, _ in
                let role = snapshot?.data()?["role"] as? String
                self?.isAdmin = (role == BuildingMember.Role.admin.rawValue)
                self?.isCoordinator = (role == BuildingMember.Role.coordinator.rawValue)
            }
    }
    
    func fetchEmergencyTypes(buildingID: String, floorID: String) {
        listener?.remove()
        
        let query = db.collection("buildings").document(buildingID).collection("floors")
            .document(floorID).collection("emergencyTypes")
            .order(by: "type")
        
        listener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            self?.emergencyTypes = documents.compactMap { doc in
                try? doc.data(as: EmergencyType.self)
            }
        }
    }
    
    func deleteEmergencyType(at offsets: IndexSet) {
        guard isAdmin else { return }
        
        // This is simplified. In a real app, delete logic requires the floorID to build the path.
        // We assume the offset provides enough context here.
        let typesToDelete = offsets.map { self.emergencyTypes[$0] }
        
        for type in typesToDelete {
            guard let typeID = type.id else { continue }
            
            // TODO: Must pass buildingID and floorID to delete this specific nested document.
            print("TODO: Implement nested delete using full path for type ID: \(typeID)")
        }
    }
    
    deinit {
        listener?.remove()
        roleListener?.remove()
    }
}
