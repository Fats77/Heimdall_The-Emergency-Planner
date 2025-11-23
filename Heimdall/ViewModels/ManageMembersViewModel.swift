//
//  ManageMembersViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 21/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
internal import Combine

@MainActor
class ManageMembersViewModel: ObservableObject {
    @Published var members: [BuildingMember] = []
    @Published var isCurrentUserAdmin = false
    @Published var isCurrentUserCoordinator = false
    @Published var isManager = false // true if admin OR coordinator
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let buildingID: String
    private let userID: String
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init(buildingID: String) {
        self.buildingID = buildingID
        self.userID = Auth.auth().currentUser?.uid ?? ""
        checkUserRole()
        listenForMembers()
    }
    
    deinit { listener?.remove() }
    
    private func checkUserRole() {
        // Fetch current user's role to determine privileges
        db.collection("buildings").document(buildingID).collection("members").document(userID)
            .getDocument { [weak self] snapshot, _ in
                let roleString = snapshot?.data()?["role"] as? String
                // FIX: Use optional chaining and rawValue comparison
                self?.isCurrentUserAdmin = (roleString == BuildingMember.Role.admin.rawValue)
                self?.isCurrentUserCoordinator = (roleString == BuildingMember.Role.coordinator.rawValue)
                self?.isManager = (self?.isCurrentUserAdmin ?? false) || (self?.isCurrentUserCoordinator ?? false)
            }
    }
    
    private func listenForMembers() {
        listener?.remove()
        listener = db.collection("buildings").document(buildingID).collection("members")
            .order(by: "role") // Sort for better grouping
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                // FIX: Use BuildingMember
                self.members = documents.compactMap { doc in
                    try? doc.data(as: BuildingMember.self)
                }
            }
    }
    
    // FIX: Using BuildingMember for parameter and role type
    func assignRole(member: BuildingMember, role: BuildingMember.Role) {
        // Admins can change any role. Coordinators can only change members/coordinators.
        if role == .admin && !isCurrentUserAdmin {
            showError(message: "Only the primary Admin can assign other Admins.")
            return
        }
        
        db.collection("buildings").document(buildingID).collection("members").document(member.id!)
            .updateData(["role": role.rawValue]) { error in
                if let error = error {
                    print("Error assigning role: \(error)")
                    self.showError(message: "Failed to assign role: \(error.localizedDescription)")
                }
            }
    }
    
    // FIX: Using BuildingMember
    func removeMember(member: BuildingMember) {
        // --- UPDATED LOGIC: Only Admin can remove others. ---
        if !isCurrentUserAdmin {
            showError(message: "Only the Admin has privileges to remove members.")
            return
        }
        
        // 1. Remove from the members subcollection
        db.collection("buildings").document(buildingID).collection("members").document(member.id!).delete()
        
        // 2. IMPORTANT: Remove the building from the user's top-level `joinedBuildings` array.
        db.collection("users").document(member.id!).updateData([
            "joinedBuildings": FieldValue.arrayRemove([buildingID])
        ])
    }
    
    func leavePlan() {
        // User is removing themselves
        guard let currentMember = members.first(where: { $0.id == userID }) else { return }
        
        // Simpler leave logic (avoids removal role check since it's self-removal)
        db.collection("buildings").document(buildingID).collection("members").document(userID).delete()
        db.collection("users").document(userID).updateData([
            "joinedBuildings": FieldValue.arrayRemove([buildingID])
        ])
    }
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
