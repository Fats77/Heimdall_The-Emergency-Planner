//
//  HomeViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var joinedBuildings: [Building] = []
    @Published var completedEvents: [Event] = []
    
    @Published var errorMessage: String?
    @Published var showError = false
    
    private var db = Firestore.firestore()
    
    private var userListener: ListenerRegistration?
    private var buildingListeners: [ListenerRegistration] = []
    private var eventListener: ListenerRegistration?
    
    //
    // --- CHECK THESE FUNCTIONS ---
    // Make sure they are 'func' and spelled correctly.
    //
    
    func fetchJoinedBuildings() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        userListener?.remove()
        buildingListeners.forEach { $0.remove() }
        buildingListeners = []
        
        let userRef = db.collection("users").document(userID)
        
        userListener = userRef.addSnapshotListener { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                print("User document not found.")
                return
            }
            
            guard let userData = try? document.data(as: AppUser.self) else { return }
            let buildingIDs = userData.joinedBuildings
            
            self.fetchBuildings(by: buildingIDs)
        }
    }
    
    func joinBuilding(with code: String) async {
        guard let userID = Auth.auth().currentUser?.uid,
              let userDisplayName = Auth.auth().currentUser?.displayName,
              let userEmail = Auth.auth().currentUser?.email
        else { return }
        
        let query = db.collection("buildings").whereField("inviteCode", isEqualTo: code).limit(to: 1)
        
        do {
            let snapshot = try await query.getDocuments()
            guard let buildingDoc = snapshot.documents.first else {
                showError(message: "Invalid invite code. Please check the code and try again.")
                return
            }
            
            let buildingID = buildingDoc.documentID
            let buildingRef = buildingDoc.reference
            
            let memberData = ["role": "member", "displayName": userDisplayName, "email": userEmail, "uid": userID]
            try await buildingRef.collection("members").document(userID).setData(memberData)
            
            try await db.collection("users").document(userID).updateData([
                "joinedBuildings": FieldValue.arrayUnion([buildingID])
            ])
            
            print("Successfully joined building!")
            
        } catch {
            showError(message: "An error occurred: \(error.localizedDescription)")
        }
    }
    
    // --- (This code is from before, make sure it's also here) ---
    
    func fetchCompletedEvents() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        eventListener?.remove()
        
        eventListener = db.collectionGroup("events")
            .whereField("status", isEqualTo: "completed")
            .order(by: "endTime", descending: true)
            .limit(to: 20)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error fetching event history: \(error.localizedDescription)")
                    return
                }
                
                guard let self = self, let documents = snapshot?.documents else { return }
                
                self.completedEvents = documents.compactMap {
                    try? $0.data(as: Event.self)
                }
            }
    }

    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }

    private func fetchBuildings(by ids: [String]) {
        buildingListeners.forEach { $0.remove() }
        buildingListeners = []
        
        if ids.isEmpty {
            self.joinedBuildings = []
            return
        }

        let listener = db.collection("buildings").whereField(FieldPath.documentID(), in: ids)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                self.joinedBuildings = documents.compactMap {
                    try? $0.data(as: Building.self)
                }
            }
        
        buildingListeners.append(listener)
    }

    deinit {
        userListener?.remove()
        buildingListeners.forEach { $0.remove() }
        eventListener?.remove()
    }
}
