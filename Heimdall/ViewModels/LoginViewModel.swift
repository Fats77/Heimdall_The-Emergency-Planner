//
//  LoginViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
internal import Combine
import CryptoKit

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var currentNonce: String?
    
    /// Handles the result from the Apple Sign In button
    func handleSignIn(authResults: ASAuthorization) async -> (User?, Error?) {
        guard let nonce = currentNonce else {
            return (nil, NSError(domain: "LoginError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing nonce."]))
        }
        
        guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
            return (nil, NSError(domain: "LoginError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not get Apple ID credential."]))
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            return (nil, NSError(domain: "LoginError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Missing identity token."]))
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            return (nil, NSError(domain: "LoginError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not decode token."]))
        }
        
        // Create the credential for Firebase
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        // Sign in to Firebase
        do {
            let authResult = try await Auth.auth().signIn(with: firebaseCredential)
            return (authResult.user, nil) // Success!
        } catch {
            return (nil, error) // Failure
        }
    }
    
    // MARK: - Cryptographic Helpers
    
    /// Creates a random string for security
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }
    
    /// Creates a SHA256 hash
    @available(iOS 13.0, *)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
