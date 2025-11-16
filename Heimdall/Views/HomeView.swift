//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//  FIXED by Gemini on 11/11/25
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showAddContactSheet = false
    @State private var showContactAddedToast = false

    var body: some View {
        NavigationStack {
            ScrollView {
                HeaderView()
                DrillPlansSection()
                EmergencyContactsSection(showAddContactSheet: $showAddContactSheet)
                HistorySection()
            }
            .background(Color.tertiary.opacity(0.4))
            .overlay(
                Group {
                    if showContactAddedToast {
                        Text("Contact added")
                            .font(.footnote.bold())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 20)
                    }
                },
                alignment: .bottom
            )
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            
            // --- 10. FIX: Use .navigationDestination, not .navigationBarBackButtonHidden ---
            // This view is now the root, so it shouldn't hide the back button
            // .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $showAddContactSheet) {
            AddContactSheet(
                showAddContactSheet: $showAddContactSheet,
                showContactAddedToast: $showContactAddedToast
            )
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack{
            Text("Hello, Imma")
                .font(.largeTitle.bold())
                .foregroundColor(Color.primary)
            Spacer()
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
        }
        .padding(.horizontal)
        .padding(.vertical,5)
    }
}
//MARK: Drill Plan Section
struct DrillPlansSection: View {
    let columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Existing Drill Plans")
                    .font(.title3.bold())
                    .foregroundColor(Color.primary)
                Spacer()
                CustomButtonView(label: "Add New", symbol: "plus", type: 1)
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1...6, id: \.self) { item in
                    DrillCardView(name: "\(item)")
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
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
//MARK: Emergency Contact Section
struct EmergencyContactsSection: View {
    @Binding var showAddContactSheet: Bool
    let contactColumns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "phone")
                    .imageScale(.large)
                Text("Personal Emergency Contact")
                    .font(.title3.bold())
            }
            .dynamicTypeSize(...DynamicTypeSize.xLarge)
            LazyVGrid(columns: contactColumns, alignment: .leading, spacing: 10) {
                ForEach(["fruit", "car", "fuitr"], id: \.self) { item in
                    ContactCardView(name: item)
                }
                Button {
                    showAddContactSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(Color.white)
                            .padding(13)
                            .background(PrimaryGradientView())
                            .cornerRadius(12)
                    }
                    .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                }
                .accessibilityLabel(Text("Add New Emergency Contact"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
//MARK: History Section
struct HistorySection: View {
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
            VStack(alignment: .leading, spacing: 12) {
                ForEach(1...6, id: \.self) { index in
                    Text("A List Item")
                        .frame(maxWidth: .infinity , alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .foregroundStyle(Color.primary)
                      .background(Color(.systemBackground))
                       // .background(Color.theme.opacity(0.2))
                        .cornerRadius(12)
                        .contextMenu {
                            Button("Delete") {}
                        }
                    Divider()
                }
            }
        }
        .padding()
      .background(Color(.systemBackground))
      //  .background(Color.theme.opacity(0.2))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}
//MARK: Add Contact Sheet Section
struct AddContactSheet: View {
    @Binding var showAddContactSheet: Bool
    @Binding var showContactAddedToast: Bool
    @State private var name: String = ""
    @State private var phone: String = ""
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.top, 8)
                Text("New Contact Details")
                    .font(.title2.bold())
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Name")
                            .font(.headline)
                        TextField("Enter contact name", text: $name)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        Text("Phone Number")
                            .font(.headline)
                        TextField("Enter phone number", text: $phone)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .keyboardType(.phonePad)
                    }
                    .padding()
                    .cornerRadius(16)
                }
                Button {
                    withAnimation(.easeInOut) {
                        showContactAddedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut) {
                            showContactAddedToast = false
                            showAddContactSheet = false
                        }
                    }
                } label: {
                    HStack {
                        Text("Save Contact")
                            .fontWeight(.semibold)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        PrimaryGradientView()
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                }
                .padding(.horizontal)
                Spacer()
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
      //  .background(Color(.systemGroupedBackground))
        .background(Color.theme.opacity(0.1))
        .overlay(
            Group {
                if showContactAddedToast {
                    Text("Contact added")
                        .font(.subheadline.bold())
                        .padding(.vertical, 9)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeInOut) {
                                    showContactAddedToast = false
                                }
                            }
                        }
                        .padding(.top, 10)
                }
            },
            alignment: .bottom
        )
        .presentationDetents([.medium])
    }
    
    // --- 13. ADD: Function to save the contact ---
    func saveContact() {
        guard !newContactName.isEmpty,
              !newContactPhone.isEmpty,
              let uid = authManager.userSession?.uid else {
            print("Error: Fields are empty or user is not logged in.")
            return
        }
        
        let newContact = EmergencyContact(name: newContactName, phone: newContactPhone)
        
        Task {
            let success = await firestoreManager.addEmergencyContact(newContact, for: uid)
            if success {
                // Update the local user model
                authManager.currentUser?.emergencyContacts?.append(newContact)
                
                // Clear fields and dismiss sheet
                newContactName = ""
                newContactPhone = ""
                showAddContactSheet = false
            } else {
                // TODO: Show an error alert to the user
                print("Error: Failed to save contact to Firestore.")
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager()) // Add mock managers for preview
        .environmentObject(FirestoreManager())
}
