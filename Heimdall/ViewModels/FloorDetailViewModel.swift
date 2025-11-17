//
//  FloorDetailViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import FirebaseFirestore
internal import Combine

@MainActor
class FloorDetailViewModel: ObservableObject {
    
    @Published var emergencyTypes: [EmergencyType] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Store IDs to avoid passing them around
    private var buildingID: String?
    private var floorID: String?
    
    deinit {
        // Remove the listener when the view is destroyed
        listener?.remove()
    }
    
    func fetchEmergencyTypes(buildingID: String, floorID: String) {
        self.buildingID = buildingID
        self.floorID = floorID
        
        // Remove old listener if it exists
        listener?.remove()
        
        // Create the query for the subcollection
        let query = db.collection("buildings").document(buildingID)
                        .collection("floors").document(floorID)
                        .collection("emergencyTypes")
        
        // Listen for realtime updates
        self.listener = query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching emergency types: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self.emergencyTypes = documents.compactMap { doc in
                try? doc.data(as: EmergencyType.self)
            }
        }
    }
    
    func deleteEmergencyType(at offsets: IndexSet) {
        guard let buildingID = buildingID, let floorID = floorID else { return }
        
        let typesToDelete = offsets.map { self.emergencyTypes[$0] }
        
        for type in typesToDelete {
            guard let typeID = type.id else { continue }
            
            // Delete from Firestore
            db.collection("buildings").document(buildingID)
                .collection("floors").document(floorID)
                .collection("emergencyTypes").document(typeID).delete { error in
                    if let error = error {
                        print("Error deleting emergency type: \(error.localizedDescription)")
                    }
                    
                    // TODO: Also delete all associated instructions and storage images
                }
        }
    }
}
