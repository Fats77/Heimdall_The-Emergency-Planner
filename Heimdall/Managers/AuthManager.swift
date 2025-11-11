//
//  AuthManager.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
internal import Combine

// This is the "Coordinator" that handles the result of the Apple Sign In
// We need this to bridge from UIKit's delegate pattern to SwiftUI
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
        
        // Get the Firebase credential from the Apple ID credential
        guard let appleAuthCredential = parent.getFirebaseCredential(from: appleIDCredential) else {
            print("ERROR: Failed to get Firebase Credential")
            return
        }
        
        // Get the full name (only provided the *first* time)
        var fullName = ""
        if let nameComponents = appleIDCredential.fullName {
            fullName = PersonNameComponentsFormatter().string(from: nameComponents)
        }
        
        // Get the email
        guard let email = appleIDCredential.email else {
            print("No email found in credential. User may have hidden it.")
            // Handle this case - you can still sign in, but you won't have the email
            // For this demo, we'll proceed with the sign-in
            parent.signInToFirebase(credential: appleAuthCredential, email: "hidden@apple.com", displayName: fullName)
            return
        }
        
        // Sign in to Firebase
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
    @Published var currentUser: AppUser? // Our custom AppUser model
    
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var firestoreManager = FirestoreManager(uid: nil)

    init() {
        // Start listening for auth changes
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.userSession = user
            if let user = user {
                // User is logged in, now fetch their profile from Firestore
                self?.firestoreManager.setUID(uid: user.uid)
                Task {
                    self?.currentUser = await self?.firestoreManager.fetchUser()
                }
            } else {
                // User is logged out
                self?.currentUser = nil
                self?.firestoreManager.setUID(uid: nil)
            }
        }
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
        // Create the coordinator
        signInCoordinator = SignInWithAppleCoordinator(parent: self)
        
        // 1. Generate a "nonce" (a one-time-use string)
        let nonce = randomNonceString()
        currentNonce = nonce
        
        // 2. Create the Apple Sign In request
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce) // Hash the nonce
        
        // 3. Create the authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = signInCoordinator
        authorizationController.presentationContextProvider = signInCoordinator
        
        // 4. Perform the request
        authorizationController.performRequests()
    }
    
    // Helper function to get the Firebase credential
    func getFirebaseCredential(from appleIDCredential: ASAuthorizationAppleIDCredential) -> AuthCredential? {
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
        
        // Create the credential
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
            if let error = error {
                print("ERROR: Firebase sign-in failed: \(error.localizedDescription)")
                return
            }
            
            // Sign in was successful!
            print("Successfully signed in to Firebase")
            guard let user = authResult?.user else { return }
            
            // Check if this is a new user
            if authResult?.additionalUserInfo?.isNewUser == true {
                print("New user. Creating user document in Firestore...")
                // Create the AppUser object
                let newAppUser = AppUser(
                    id: user.uid,
                    email: email,
                    displayName: displayName,
                    emergencyContacts: [] // Start with an empty list
                )
                
                // Save to Firestore
                Task {
                    await self?.firestoreManager.createUser(user: newAppUser)
                    self?.currentUser = newAppUser
                }
            } else {
                print("Existing user. Welcome back.")
                // The auth listener will automatically fetch their data
            }
        }
    }
}

// MARK: - Sign in with Apple Presentation Context
extension SignInWithAppleCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }
        return window ?? UIApplication.shared.windows.first!
    }
}
// MARK: - Cryptography Helpers
import CryptoKit

private func randomNonceString(length: Int = 32) -> String {
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

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}
