//
//  AuthService.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices // Import Apple's service
internal import Combine

@MainActor
class AuthService: ObservableObject {
    
    @Published var currentUser: User?
    
    private var db = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        // Set up a listener that fires when the user signs in or out
        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.currentUser = user
        }
    }
    
    deinit {
        // Clean up the listener
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
    
    /// Creates the user document in Firestore *only* if it's their first time
    func handleSignInSuccess(user: User) async {
        let userRef = db.collection("users").document(user.uid)
        
        do {
            let document = try await userRef.getDocument()
            
            // If the document doesn't exist, it's a new user
            if !document.exists {
                let newUser = AppUser(
                    uid: user.uid,
                    name: user.displayName ?? "Anonymous",
                    email: user.email ?? "",
                    joinedBuildings: []
                )
                // Create the user document
                try userRef.setData(from: newUser)
                print("New user document created in Firestore.")
            } else {
                print("Returning user. Welcome back.")
            }
        } catch {
            print("Error checking or creating user document: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
