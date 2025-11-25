//
//  InstructionDetailViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 25/11/25.
//
import FirebaseFirestore
import Kingfisher
internal import Combine

// MARK: - Instruction Detail ViewModel
@MainActor
class InstructionDetailViewModel: ObservableObject {
    @Published var floors: [Floor] = []
    @Published var emergencyType: EmergencyType?
    
    private var db = Firestore.firestore()
    
    func fetchData(buildingID: String, emergencyTypeID: String) {
        // Fetch all floors for the selector
        db.collection("buildings").document(buildingID).collection("floors")
            .getDocuments { [weak self] snapshot, _ in
                // FIX: Corrected snapshot mapping
                self?.floors = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Floor.self)
                } ?? []
                self?.fetchEmergencyType(buildingID: buildingID, emergencyTypeID: emergencyTypeID)
            }
    }
    
    private func fetchEmergencyType(buildingID: String, emergencyTypeID: String) {
        // Use Collection Group Query to find the emergency type anywhere under the building
        db.collectionGroup("emergencyTypes")
            // Apply filtering constraints to only look within the relevant building structure
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: "buildings/\(buildingID)/")
            .whereField(FieldPath.documentID(), isLessThan: "buildings/\(buildingID)0")
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self else { return }
                
                // Find the specific document by ID (since the query is broad)
                if let doc = snapshot?.documents.first(where: { $0.documentID == emergencyTypeID }) {
                    self.emergencyType = try? doc.data(as: EmergencyType.self)
                }
            }
    }
}
