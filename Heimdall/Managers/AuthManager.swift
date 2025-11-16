//
//  AuthManager.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//  FIXED AGAIN by Gemini on 11/14/25
//

import Foundation
import FirebaseAuth
import AuthenticationServices
internal import Combine // <-- Fixed the 'internal import' syntax

// This is the "Coordinator" that handles the result of the Apple Sign In
class SignInWithAppleCoordinator: NSObject, ASAuthorizationControllerDelegate {
    var parent: AuthManager
    
    init(parent: AuthManager) {
        self.parent = parent
    }
    
    // Handle successful login
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("ERROR: Failed to get Apple ID Credential")
            return
        }
        
        guard let appleAuthCredential = parent.getFirebaseCredential(from: appleIDCredential) else {
            print("ERROR: Failed to get Firebase Credential")
            return
        }
        
        var fullName = ""
        if let nameComponents = appleIDCredential.fullName {
            fullName = PersonNameComponentsFormatter().string(from: nameComponents)
        }
        
        guard let email = appleIDCredential.email else {
            print("No email found in credential. User may have hidden it.")
            parent.signInToFirebase(credential: appleAuthCredential, email: "hidden@apple.com", displayName: fullName)
            return
        }
        
        parent.signInToFirebase(credential: appleAuthCredential, email: email, displayName: fullName)
    }
    
    // Handle login failure
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("ERROR: Sign in with Apple failed: \(error.localizedDescription)")
    }
}


@MainActor // Ensures all UI updates run on the main thread
class AuthManager: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    
    // --- 1. THE "GATEKEEPER" ---
    @Published var isUserDataReady: Bool = false
    
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    let firestoreManager = FirestoreManager()

    init() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.userSession = user
            
            // --- 2. MODIFIED LOGIC ---
            if let user = user {
                // This block now *only* handles the "app launch" case.
                // If data isn't ready (app just launched), fetch it.
                if self?.isUserDataReady == false {
                    print("Auth listener: User is logged in, fetching data...")
                    Task {
                        await self?.loadUserData()
                    }
                }
            } else {
                // User is logged out, reset everything
                print("Auth listener: User is logged out.")
                self?.currentUser = nil
                self?.isUserDataReady = false
            }
        }
    }
    
    // --- 3. NEW HELPER FUNCTION ---
    // A single, reusable function to load all user data.
    func loadUserData() async {
        print("Loading user data...")
        self.currentUser = await self.firestoreManager.fetchUser()
        await self.firestoreManager.fetchUserBuildings()
        
        // This is the gate.
        self.isUserDataReady = true
        print("User data is ready.")
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign in with Apple Logic
    
    private var currentNonce: String?
    private var signInCoordinator: SignInWithAppleCoordinator?

    func startSignInWithApple() {
        // ... (This function is correct, no changes needed)
        signInCoordinator = SignInWithAppleCoordinator(parent: self)
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha268(nonce) // Using your sha268 function name
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = signInCoordinator
        authorizationController.presentationContextProvider = signInCoordinator
        authorizationController.performRequests()
    }
    
    func getFirebaseCredential(from appleIDCredential: ASAuthorizationAppleIDCredential) -> AuthCredential? {
        // ... (This function is correct, no changes needed)
        guard let nonce = currentNonce else {
            print("ERROR: Missing nonce")
            return nil
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("ERROR: Missing identity token")
            return nil
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("ERROR: Could not convert token to string")
            return nil
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        return credential
    }
    
    // Helper function to sign into Firebase
    func signInToFirebase(credential: AuthCredential, email: String, displayName: String) {
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("ERROR: Firebase sign-in failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else { return }
            
            // --- 4. SIMPLIFIED TASK ---
            // This is the flow for a *new* sign-in
            Task {
                let existingUser = await self.firestoreManager.fetchUser()
                
                if existingUser == nil {
                    print("User document missing. Creating new user document...")
                    let newDisplayName = displayName.isEmpty ? "New User" : displayName
                    let newEmail = email.isEmpty ? "hidden@apple.com" : email
                    
                    let newAppUser = AppUser(
                        id: user.uid,
                        email: newEmail,
                        displayName: newDisplayName,
                        emergencyContacts: []
                    )
                    
                    await self.firestoreManager.createUser(user: newAppUser)
                } else {
                    print("Existing user document found.")
                }
                
                // --- 5. THE MOST IMPORTANT PART ---
                // After sign-in and user creation,
                // we call the *same* helper function to load all data
                // and open the gate.
                await self.loadUserData()
            }
        }
    }
}

// MARK: - Sign in with Apple Presentation Context
extension SignInWithAppleCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // ... (This function is correct, no changes needed)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow }) else {
            
            fatalError("Could not find a valid window to present Sign in with Apple.")
        }
        
        return window
    }
}

// MARK: - Cryptography Helpers
import CryptoKit

private func randomNonceString(length: Int = 32) -> String {
    // ... (This function is correct, no changes needed)
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate random bytes. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

// Note: Your file had sha256, but your code called sha268.
// I've used the function name you called.
@available(iOS 13, *)
private func sha268(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
