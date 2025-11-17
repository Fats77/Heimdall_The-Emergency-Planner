//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//  FIXED by Gemini on 11/11/25
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct HomeView: View {
    
    // Use the ViewModel to manage all data for this screen
    @StateObject private var viewModel = HomeViewModel()
    
    // Get the global AuthManager (as you named it)
    @EnvironmentObject var authManager: AuthService // Using our AuthService
    
    // States for presenting sheets and alerts
    @State private var isCreatingPlan = false
    @State private var isJoiningPlan = false
    @State private var isShowingProfile = false
    
    // State for the "Join" alert
    @State private var inviteCode = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                // Pass user data and profile binding to the header
                HeaderView(
                    name: authManager.currentUser?.displayName ?? "User",
                    photoURL: authManager.currentUser?.photoURL,
                    isShowingProfile: $isShowingProfile
                )
                
                // Pass the building data and bindings to the plans section
                MyPlansSection(
                    joinedBuildings: viewModel.joinedBuildings,
                    isCreatingPlan: $isCreatingPlan,
                    isJoiningPlan: $isJoiningPlan
                )
                
                // Pass the completed events to the history section
                HistorySection(events: viewModel.completedEvents)
            }
            .background(Color.tertiary.opacity(0.4))
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .navigationTitle("Home") // Add a title for the navigation stack
            .navigationBarHidden(true) // Hide the default bar
        }
        .refreshable(action: {
            viewModel.fetchJoinedBuildings()
            viewModel.fetchCompletedEvents()
        })
        // Sheet for Creating a new plan
        .sheet(isPresented: $isCreatingPlan) {
            NavigationStack { CreateBuildingView() }
        }
        // Sheet for viewing the Profile
        .sheet(isPresented: $isShowingProfile) {
            NavigationStack {
                // We will build this view next
                ProfileView()
                    .environmentObject(authManager)
            }
        }
        // Alert for Joining a plan
        .alert("Join a Plan", isPresented: $isJoiningPlan, actions: {
            TextField("Enter Invite Code", text: $inviteCode)
                .autocapitalization(.allCharacters)
            
            Button("Join", action: {
                Task {
                   await viewModel.joinBuilding(with: inviteCode)
                   inviteCode = "" // Clear the field
                }
            })
            Button("Cancel", role: .cancel, action: { inviteCode = "" })
        }, message: {
            Text("Please enter the 6-character invite code provided by your admin.")
        })
        // Alert for any errors
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage, actions: { _ in
            Button("OK") {}
        }, message: { message in
            Text(message)
        })
        .onAppear {
            // Fetch all data when the view appears
            viewModel.fetchJoinedBuildings()
            viewModel.fetchCompletedEvents()
            NotificationService.shared.requestNotificationPermission()
        }
    }
}

struct HeaderView: View {
    let name: String
    let photoURL: URL?
    @Binding var isShowingProfile: Bool
    
    var body: some View {
        HStack {
            Text("Hello, \(name)")
                .font(.largeTitle.bold())
                .foregroundColor(Color.primary)
            
            Spacer()
            
            Button {
                isShowingProfile = true
            } label: {
                // TODO: Load image from photoURL
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(color: Color.tertiary.opacity(0.4), radius: 5, x: -2, y: 7)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

//MARK: Drill Plan Section
struct MyPlansSection: View {
    let joinedBuildings: [CreateBuildingViewModel.Building]
    @Binding var isCreatingPlan: Bool
    @Binding var isJoiningPlan: Bool
    
    let columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Plans")
                    .font(.title3.bold())
                    .foregroundColor(Color.primary)
                
                Spacer()
                
                // "Join" Button
                Button {
                    isJoiningPlan = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.callout.bold())
                        .padding(8)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // "Add New" (Create) Button
                Button {
                    isCreatingPlan = true
                } label: {
                    Image(systemName: "plus")
                        .font(.callout.bold())
                        .padding(8)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            
            if joinedBuildings.isEmpty {
                Text("Tap 'Join' or 'Add' to get started.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(joinedBuildings) { building in
                        // Wrap the card in a link to the detail view
                        NavigationLink(destination: BuildingDetailView(building: building)) {
                            DrillCardView(building: building)
                        }
                    }
                }
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

//MARK: History Section
struct HistorySection: View {
    let events: [Event] // Use the 'Event' model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "clock")
                    .imageScale(.large)
                Text("History")
                    .font(.title3.bold())
            }
            .padding(.leading, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if events.isEmpty {
                Text("No completed drills or events yet.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 50)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(events) { event in
                        HistoryCardView(event: event)
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

//MARK: History Card View
struct HistoryCardView: View {
    let event: Event
    
    private var endDateText: String {
        if let endTime = event.endTime {
            // If it exists, convert the Timestamp to a Date and format it
            let date = endTime.dateValue()
            return date.formatted(date: .abbreviated, time: .omitted)
        } else {
            // If endTime is nil, the event is still in progress
            return "In Progress"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading) {
                Text(event.eventName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(endDateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .background(Color(.systemBackground)) // Allow tapping the whole row
        .contextMenu {
            Button("Delete", role: .destructive) {}
        }
    }
}

#Preview {
//    HomeView()
//        .environmentObject(AuthManager()) // Add mock managers for preview
//        .environmentObject(FirestoreManager())
}
