//
//  FirestoreManager.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//  FIXED by Gemini on 11/11/25
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions
internal import Combine // <-- 1. Fixed syntax error
import FirebaseAuth // <-- 2. ADDED THIS: Needed for the fix

@MainActor
class FirestoreManager: ObservableObject {
    
    @Published var userBuildings: [Building] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var functions = Functions.functions()
    private var uid: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() { }
    
    
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
    
    func addEmergencyContact(_ contact: EmergencyContact, for uid: String) async -> Bool {
        do {
            // This uses FieldValue.arrayUnion to safely add a new contact
            let contactData = ["name": contact.name, "phone": contact.phone]
            
            try await db.collection("users").document(uid).updateData([
                "emergencyContacts": FieldValue.arrayUnion([contactData])
            ])
            return true
        } catch {
            print("Error adding emergency contact: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Building Functions
        
    func fetchUserBuildings() async {
        guard let uid = uid else { return }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            // 1. Get the "member" documents
            let memberSnapshot = try await db.collectionGroup("members")
                                             .whereField("uid", isEqualTo: uid)
                                             .getDocuments()
            
            let memberDocs = memberSnapshot.documents
            
            // 2. Get the parent "building" references
            let buildingRefs = memberDocs.compactMap { $0.reference.parent.parent }
            
            if buildingRefs.isEmpty {
                // No buildings found
                await MainActor.run {
                    self.userBuildings = []
                    self.isLoading = false
                }
                return
            }
            
            // 3. Fetch all building documents concurrently
            var fetchedBuildings: [Building] = []
            try await withThrowingTaskGroup(of: Building?.self) { group in
                for ref in buildingRefs {
                    group.addTask {
                        return await self.fetchBuilding(by: ref.documentID)
                    }
                }
                
                for try await building in group {
                    if let building = building {
                        fetchedBuildings.append(building)
                    }
                }
            }
            
            // 4. Update the UI
            await MainActor.run {
                self.userBuildings = fetchedBuildings
                self.isLoading = false
            }
            
        } catch {
            print("Error fetching user buildings: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
        
    // --- HELPER FUNCTION ---
    private func fetchBuilding(by id: String) async -> Building? {
        do {
            return try await db.collection("buildings").document(id).getDocument(as: Building.self)
        } catch {
            print("Error fetching building \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    func createBuilding(name: String, description: String, creator: AppUser) async -> Bool {
        guard let uid = uid else { return false }
        
        isLoading = true
        
        do {
            let data: [String: Any] = [
                "name": name,
                "description": description,
                "admin": [
                    "uid": uid,
                    "displayName": creator.displayName,
                    "email": creator.email // Pass the email from the creator object
                ]
            ]
            
            // Call the Cloud Function
            let result = try await functions.httpsCallable("createBuilding").call(data)
            print("Cloud function result: \(result.data)")
            
            // Refresh our building list
            await fetchUserBuildings()
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
            
            if let data = result.data as? [String: Any], data["success"] as? Bool == true {
                // Refresh our building list
                await fetchUserBuildings()
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
    
    // MARK: - Member Functions
        
    // Fetches all members for a specific building
    func fetchMembers(forBuildingId buildingId: String) async -> [BuildingMember] {
        do {
            let snapshot = try await db.collection("buildings").document(buildingId)
                                     .collection("members").getDocuments()
            
            let members = snapshot.documents.compactMap { doc in
                try? doc.data(as: BuildingMember.self)
            }
            return members
            
        } catch {
            print("Error fetching members: \(error.localizedDescription)")
            return []
        }
    }
        
    // Updates the role for a specific user in a specific building
    func updateMemberRole(userId: String, buildingId: String, newRole: BuildingMember.Role) async -> Bool {
        do {
            try await db.collection("buildings").document(buildingId)
                      .collection("members").document(userId)
                      .updateData(["role": newRole.rawValue])
            return true
        } catch {
            print("Error updating role: \(error.localizedDescription)")
            return false
        }
    }
}
