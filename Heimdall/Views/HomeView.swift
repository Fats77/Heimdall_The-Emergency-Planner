//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//  FIXED by Gemini on 11/11/25
//

import SwiftUI
import FirebaseAuth
import Kingfisher // For loading profile and building images
import FirebaseCore

// MARK: - Theme Colors (Based on Design Image)
extension Color {
    static let tagActive = Color(red: 0.3, green: 0.7, blue: 0.3) // Green for Active
    static let tagPending = Color(red: 0.95, green: 0.7, blue: 0.2) // Yellow/Orange for Pending
    static let secondaryBackground = Color(UIColor.systemGray6)
}

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authManager: AuthService
    
    @State private var isCreatingPlan = false
    @State private var isJoiningPlan = false
    @State private var isShowingProfile = false
    
    @State private var inviteCode = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 1. TOP HEADER & ACTION BUTTONS
                    HeaderSection(
                        userDisplayName: authManager.currentUser?.displayName ?? "User",
                        userPhotoURL: authManager.currentUser?.photoURL,
                        isCreatingPlan: $isCreatingPlan,
                        isJoiningPlan: $isJoiningPlan,
                        isShowingProfile: $isShowingProfile
                    )
                    .padding(.bottom, 20)
                    
                    // 2. MY PLANS SECTION
                    MyPlansSection(
                        joinedBuildings: viewModel.joinedBuildings
                    )
                    
                    // 3. HISTORY SECTION (Replaced Emergency Contacts)
                    HistorySection(
                        events: viewModel.completedEvents
                    )
                }
            }
            .background(Color.secondaryBackground)
            .ignoresSafeArea(edges: .top) // Extend background under the safe area
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isCreatingPlan) {
            NavigationStack { CreateBuildingView() }
        }
        .sheet(isPresented: $isShowingProfile) {
            NavigationStack {
                ProfileView()
                    .environmentObject(authManager)
            }
        }
        // Alert for Joining a plan (Same as before)
        .alert("Join a Plan", isPresented: $isJoiningPlan, actions: {
            TextField("Enter Invite Code", text: $inviteCode)
                .autocapitalization(.allCharacters)
            Button("Join", action: {
                Task {
                   await viewModel.joinBuilding(with: inviteCode)
                   inviteCode = ""
                }
            })
            Button("Cancel", role: .cancel, action: { inviteCode = "" })
        }, message: {
            Text("Please enter the 6-character invite code provided by your admin.")
        })
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage, actions: { _ in
            Button("OK") {}
        }, message: { message in
            Text(message)
        })
        .onAppear {
            let _ = EventService.shared
            viewModel.fetchJoinedBuildings()
            viewModel.fetchCompletedEvents()
            NotificationService.shared.requestNotificationPermission()
        }
    }
}

// MARK: - 1. Header Section
struct HeaderSection: View {
    let userDisplayName: String
    let userPhotoURL: URL?
    @Binding var isCreatingPlan: Bool
    @Binding var isJoiningPlan: Bool
    @Binding var isShowingProfile: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background color that curves slightly
            Color.theme
                .frame(height: 220)
            
            VStack(alignment: .leading, spacing: 10) {
                // Top Row (Greeting and Profile)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hello, \(userDisplayName)")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Stay prepared, stay safe")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Profile Button (Top Right)
                    Button {
                        isShowingProfile = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 40, height: 40)
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.top, 70) // Push down from safe area
                
                Spacer()
                
                // Action Buttons (Create Plan / Join Plan)
                HStack(spacing: 16) {
                    ActionButton(title: "Create Plan", icon: "plus", action: { isCreatingPlan = true })
                    ActionButton(title: "Join Plan", icon: "link", action: { isJoiningPlan = true })
                }
                .padding(.bottom, 20) // Spacing from content below
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2)) // Slightly transparent background
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
    }
}


// MARK: - 2. My Plans Section (Cards)
struct MyPlansSection: View {
    let joinedBuildings: [Building]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Section Header
            HStack {
                Text("My Plans")
                    .font(.title2.bold())
            }
            .padding(.horizontal)
            
            // Cards List
            if joinedBuildings.isEmpty {
                Text("Tap 'Join Plan' or 'Create Plan' to get started.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(joinedBuildings) { building in
                    NavigationLink(destination: BuildingDetailView(building: building)) {
                        BuildingCard(building: building)
                    }
                }
            }
        }
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Building Card Component
struct BuildingCard: View {
    let building: Building
    
    // Placeholder logic for the status tag (needs actual Firestore event check)
    @State private var mockStatus: Bool = Bool.random() // Temp: Mock Active/Pending
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon / Photo (using a placeholder based on building name hash)
            VStack {
                if let photoURLString = building.buildingImageURL, let url = URL(string: photoURLString) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Image(systemName: "building.2.fill")
                        .resizable()
                        .padding(8)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Color.theme)
                        .cornerRadius(10)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(building.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Description (Subtitle)
                Text(building.description ?? "Plan details available.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
//                HStack(spacing: 15) {
//                    Text("?? participants")
//                        .font(.caption2)
//                        .foregroundColor(.secondary)
//                }
//                .padding(.top, 4)
            }
            Spacer()
            HStack(alignment: .center){
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
}


// MARK: - 3. History Section (Replacing Emergency Contacts)
struct HistorySection: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("History")
                    .font(.title2.bold())
            }
            .padding(.horizontal)
            
            // List of History Items
            if events.isEmpty {
                Text("No completed drills or events yet.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(events) { event in
                    HistoryCard(event: event)
                }
            }
        }
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - History Card Component (Styled like the Contact Card)
struct HistoryCard: View {
    let event: Event
    
    private var eventDate: String {
        if let endTime = event.endTime {
            return endTime.dateValue().formatted(date: .abbreviated, time: .omitted)
        }
        return "N/A"
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon placeholder
            Image(systemName: "clock.badge.checkmark.fill")
                .resizable()
                .padding(10)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(Color.gray.opacity(0.7))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(event.eventName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Completed: \(eventDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Call icon replaced with a detail arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
}

#Preview {
//    HomeView()
//        .environmentObject(AuthManager()) // Add mock managers for preview
//        .environmentObject(FirestoreManager())
}
