//
//  FirestoreManager.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//


import Foundation
import FirebaseFirestore
import FirebaseFunctions
internal import Combine

@MainActor
class FirestoreManager: ObservableObject {
    
    // Published properties will update our UI automatically
    @Published var userBuildings: [Building] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var functions = Functions.functions()
    private var uid: String?

    // We initialize this with the user's ID from AuthManager
    init(uid: String?) {
        self.uid = uid
        
        if uid != nil {
            fetchUserBuildings()
        }
    }
    
    // Helper to update the UID if AuthManager initializes it later
    func setUID(uid: String?) {
        self.uid = uid
        if uid == nil {
            userBuildings = [] // Clear data on log out
        }
    }

    // MARK: - User Functions
    
    func fetchUser() async -> AppUser? {
        guard let uid = uid else { return nil }
        
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            return try document.data(as: AppUser.self)
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createUser(user: AppUser) async {
        guard let uid = user.id else { return }
        do {
            // Use .setData(from:) to convert our Swift struct to a DB document
            try db.collection("users").document(uid).setData(from: user)
        } catch {
            print("Error creating user in Firestore: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Building Functions
    
    func fetchUserBuildings() {
        guard let uid = uid else { return }
        
        isLoading = true
        
        // This query finds all buildings where the user is a member
        db.collectionGroup("members").whereField(FieldPath.documentID(), isEqualTo: uid)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching user buildings: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let memberDocs = querySnapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                // Now that we have the "member" docs, we need to get their
                // parent "building" documents
                let buildingRefs = memberDocs.map { $0.reference.parent.parent! }
                
                if buildingRefs.isEmpty {
                    self.isLoading = false
                    self.userBuildings = []
                    return
                }
                
                // Fetch all building documents
                Task {
                    var buildings: [Building] = []
                    for ref in buildingRefs {
                        if let building = await self.fetchBuilding(by: ref.documentID) {
                            buildings.append(building)
                        }
                    }
                    self.userBuildings = buildings
                    self.isLoading = false
                }
            }
    }
    
    private func fetchBuilding(by id: String) async -> Building? {
        do {
            return try await db.collection("buildings").document(id).getDocument(as: Building.self)
        } catch {
            print("Error fetching building \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    // --- THIS IS THE CLOUD FUNCTION PART ---
    // We call a cloud function to ensure the invite code is unique
    // and to handle the logic securely on the server.
    func createBuilding(name: String, description: String, creator: AppUser) async -> Bool {
        guard let uid = uid, let email: String? = creator.email else { return false }
        
        isLoading = true
        
        do {
            let data: [String: Any] = [
                "name": name,
                "description": description,
                "admin": [
                    "uid": uid,
                    "displayName": creator.displayName,
                    "email": email
                ]
            ]
            
            // Call the Cloud Function
            let result = try await functions.httpsCallable("createBuilding").call(data)
            print("Cloud function result: \(result.data)")
            
            // Refresh our building list
            fetchUserBuildings()
            return true
            
        } catch {
            print("Error calling createBuilding function: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    func joinBuilding(inviteCode: String) async -> Bool {
        guard uid != nil else { return false }
        
        isLoading = true
        
        do {
            // Call the Cloud Function
            let result = try await functions.httpsCallable("joinBuilding").call(["inviteCode": inviteCode])
            
            // The function will return data, e.g., { "success": true } or { "error": "Invalid code" }
            if let data = result.data as? [String: Any], data["success"] as? Bool == true {
                // Refresh our building list
                fetchUserBuildings()
                return true
            } else {
                print("Error joining building: \( (result.data as? [String: Any])?["error"] ?? "Unknown error" )")
                isLoading = false
                return false
            }
        } catch {
            print("Error calling joinBuilding function: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Drill Functions
        
    func saveDrill(_ drill: Drill, forBuildingId buildingId: String?) async -> Bool {
        guard let buildingId = buildingId else {
            print("Error: Building ID is nil")
            return false
        }
        
        do {
            // This will create a new document in the "drills" sub-collection
            // and automatically set its data from our Swift 'Drill' struct.
            try db.collection("buildings").document(buildingId)
                  .collection("drills").document()
                  .setData(from: drill)
            
            print("Drill saved successfully!")
            return true
        } catch {
            print("Error saving drill: \(error.localizedDescription)")
            return false
        }
    }
}
