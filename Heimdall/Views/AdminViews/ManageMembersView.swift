//
//  ManageMembersView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 21/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
internal import Combine

enum UserRole: String {
    case admin, coordinator, member
}
// Using the global BuildingMember (which includes displayName)
typealias Member = BuildingMember

struct ManageMembersView: View {
    let buildingID: String
    @StateObject private var viewModel: ManageMembersViewModel
    
    init(buildingID: String) {
        self.buildingID = buildingID
        _viewModel = StateObject(wrappedValue: ManageMembersViewModel(buildingID: buildingID))
    }
    
    var body: some View {
        List {
            Section(header: Text("Members (\(viewModel.members.count))")) {
                ForEach(viewModel.members) { member in
                    // Prevent context menu options for the user managing themselves (unless leaving)
                    let isSelf = member.id == Auth.auth().currentUser?.uid
                    
                    MemberRow(member: member) // FIX: Removed unused isCurrentUserAdmin parameter
                        .contextMenu {
                            // Assign Role Menu (Admins/Coordinators can change roles, but Admin role is limited)
                            if viewModel.isManager && !isSelf {
                                Menu {
                                    // FIX: Using BuildingMember.Role.coordinator and member
                                    Button("Assign as Coordinator") { viewModel.assignRole(member: member, role: .coordinator) }
                                    Button("Assign as Member") { viewModel.assignRole(member: member, role: .member) }
                                    if viewModel.isCurrentUserAdmin { // Only the Admin can grant Admin status
                                        Button("Assign as Admin") { viewModel.assignRole(member: member, role: .admin) }
                                    }
                                } label: {
                                    Label("Change Role", systemImage: "person.badge.shield.checkmark")
                                }
                            }
                            
                            // Remove Member (ONLY ADMINS can remove others - the specific user requirement)
                            if viewModel.isCurrentUserAdmin && !isSelf {
                                Button(role: .destructive) {
                                    viewModel.removeMember(member: member)
                                } label: {
                                    Label("Remove Member", systemImage: "trash")
                                }
                            }
                            
                            // User leaving the plan (only option for themselves)
                            if isSelf {
                                Button(role: .destructive) {
                                    viewModel.leavePlan()
                                } label: {
                                    Label("Leave Plan", systemImage: "figure.walk.motion")
                                }
                            }
                        }
                }
            }
        }
        .navigationTitle("Manage Members")
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in } message: { Text($0) }
    }
}

struct MemberRow: View {
    let member: BuildingMember // FIX: Use BuildingMember
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill").font(.title)
            
            VStack(alignment: .leading) {
                Text(member.displayName).font(.headline) // FIX: Use displayName
                Text(member.email).font(.caption).foregroundColor(.secondary) // FIX: Use email
            }
            
            Spacer()
            
            // Role Tag
            Text(member.role.rawValue.capitalized) // FIX: Use member.role.rawValue
                .font(.caption2.bold())
                .foregroundColor(member.role == .admin ? .red : member.role == .coordinator ? .orange : .blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)
        }
    }
}

