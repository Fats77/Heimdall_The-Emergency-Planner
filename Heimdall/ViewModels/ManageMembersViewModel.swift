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
    @Published var allMembers: [BuildingMember] = []
    @Published var searchText: String = "" // Feature 10
    
    @Published var isCurrentUserAdmin = false
    @Published var isCurrentUserCoordinator = false
    @Published var isManager = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let buildingID: String
    private let userID: String
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Computed properties for filtered/categorized lists
    var filteredMembers: [BuildingMember] {
        if searchText.isEmpty {
            return allMembers
        } else {
            return allMembers.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var adminMembers: [BuildingMember] {
        filteredMembers.filter { $0.role == .admin }
    }
    var coordinatorMembers: [BuildingMember] {
        filteredMembers.filter { $0.role == .coordinator }
    }
    var regularMembers: [BuildingMember] {
        filteredMembers.filter { $0.role == .member }
    }
    
    init(buildingID: String) {
        self.buildingID = buildingID
        self.userID = Auth.auth().currentUser?.uid ?? ""
        checkUserRole()
        listenForMembers()
    }
    
    deinit { listener?.remove() }
    
    private func checkUserRole() {
        db.collection("buildings").document(buildingID).collection("members").document(userID)
            .getDocument { [weak self] snapshot, _ in
                let roleString = snapshot?.data()?["role"] as? String
                self?.isCurrentUserAdmin = (roleString == BuildingMember.Role.admin.rawValue)
                self?.isCurrentUserCoordinator = (roleString == BuildingMember.Role.coordinator.rawValue)
                self?.isManager = (self?.isCurrentUserAdmin ?? false) || (self?.isCurrentUserCoordinator ?? false)
            }
    }
    
    private func listenForMembers() {
        listener?.remove()
        // Listen to all members, ordered by role (to group them)
        listener = db.collection("buildings").document(buildingID).collection("members")
            .order(by: "role", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.allMembers = documents.compactMap { doc in
                    try? doc.data(as: BuildingMember.self)
                }
            }
    }
    
    func assignRole(member: BuildingMember, role: BuildingMember.Role) {
        // Validation: Only Admin can grant Admin status
        if role == .admin && !isCurrentUserAdmin {
            showError(message: "Only the Admin can assign other Admins.")
            return
        }
        
        // Validation: Coordinators cannot demote Admins
        if isCurrentUserCoordinator && member.role == .admin {
            showError(message: "Coordinators cannot modify the Admin role.")
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
    
    // Feature 7: Admin removes member (Role restriction enforced)
    func removeMember(member: BuildingMember) {
        if !isCurrentUserAdmin {
            showError(message: "Only the Admin has privileges to remove members.")
            return
        }
        
        // 1. Remove from the members subcollection
        db.collection("buildings").document(buildingID).collection("members").document(member.id!).delete()
        
        // 2. Remove the building from the user's top-level joinedBuildings array.
        db.collection("users").document(member.id!).updateData([
            "joinedBuildings": FieldValue.arrayRemove([buildingID])
        ])
    }
    
    func leavePlan() {
        // Logic for user leaving themselves (handled in BuildingDetailViewModel for navigation)
        
        // We trigger the same logic as removeMember, relying on the delete logic
        // to handle the cleanup. We don't need the role check here since the user
        // initiated the action on themselves, but we rely on the main view
        // to navigate away after deletion.
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
