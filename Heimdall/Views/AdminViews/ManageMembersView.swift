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
import Kingfisher
// Using the global BuildingMember (which includes displayName)
typealias Member = BuildingMember
// ----------------------------------------------------------------------


struct ManageMembersView: View {
    let buildingID: String
    @StateObject private var viewModel: ManageMembersViewModel
    
    // Feature 10: Search functionality
    @State private var searchText: String = ""
    
    init(buildingID: String) {
        self.buildingID = buildingID
        _viewModel = StateObject(wrappedValue: ManageMembersViewModel(buildingID: buildingID))
    }
    
    var body: some View {
        List {
            // FIX: Pass the ViewModel to the helper view to allow direct observation of the filtered lists.
            // This cleanly breaks the complexity without fighting the compiler.
            MemberSection(
                title: "Admins (\(viewModel.adminMembers.count))",
                members: viewModel.adminMembers,
                viewModel: viewModel
            )
            
            MemberSection(
                title: "Coordinators (\(viewModel.coordinatorMembers.count))",
                members: viewModel.coordinatorMembers,
                viewModel: viewModel
            )
            
            MemberSection(
                title: "Members (\(viewModel.regularMembers.count))",
                members: viewModel.regularMembers,
                viewModel: viewModel
            )
            
            if viewModel.filteredMembers.isEmpty && !searchText.isEmpty {
                Text("No users match \"\(searchText)\"")
            }
        }
        .navigationTitle("Manage Members")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search members")
        // FIX: Corrected assignment in onChange to use the ViewModel's @Published property directly.
        .onChange(of: searchText) { newValue in
            viewModel.searchText = newValue
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in } message: { Text($0) }
    }
}

// MARK: - Compiler Helper Struct
struct MemberSection: View {
    let title: String
    let members: [BuildingMember]
    // The view model is observed here to ensure all nested actions work correctly
    @ObservedObject var viewModel: ManageMembersViewModel

    var body: some View {
        Section(header: Text(title)) {
            ForEach(members) { member in
                MemberRow(member: member)
                    .contextMenu {
                         memberContextMenu(for: member)
                    }
            }
        }
    }
    
    // MARK: - Context Menu Actions (Feature 3)
    @ViewBuilder
    private func memberContextMenu(for member: Member) -> some View {
        let isSelf = member.id == Auth.auth().currentUser?.uid
        
        // 1. Change Role Menu (Visible to Admins/Coordinators)
        if viewModel.isManager && !isSelf {
            Menu {
                Button("Assign as Coordinator") { viewModel.assignRole(member: member, role: .coordinator) }
                Button("Assign as Member") { viewModel.assignRole(member: member, role: .member) }
                if viewModel.isCurrentUserAdmin {
                    Button("Assign as Admin") { viewModel.assignRole(member: member, role: .admin) }
                }
            } label: {
                Label("Change Role", systemImage: "person.badge.shield.checkmark")
            }
        }
        
        // 2. Remove Member (Visible ONLY to Admins - enforced requirement)
        if viewModel.isCurrentUserAdmin && !isSelf {
            Button(role: .destructive) {
                viewModel.removeMember(member: member)
            } label: {
                Label("Remove Member", systemImage: "trash")
            }
        }
        
        // 3. Leave Plan (Visible only to self)
        if isSelf {
            Button(role: .destructive) {
                viewModel.leavePlan()
            } label: {
                Label("Leave Plan", systemImage: "figure.walk.motion")
            }
        }
    }
}

// MARK: - Member Row Component (Unchanged)
struct MemberRow: View {
    let member: BuildingMember
    
    var body: some View {
        HStack {
            
            if let profilePhotoURL = member.profilePhotoURL, let url = URL(string: profilePhotoURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .padding(8)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .background(Color.theme.opacity(0.7))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading) {
                Text(member.displayName).font(.headline)
                Text(member.email).font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Role Tag
            Text(member.role.rawValue.capitalized)
                .font(.caption2.bold())
                .foregroundColor(member.role == .admin ? .red : member.role == .coordinator ? .orange : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)
        }
    }
}

