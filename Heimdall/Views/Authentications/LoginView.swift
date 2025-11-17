//
//  LoginView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authService: AuthService // Get the service
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Welcome to Your\nEmergency Planner")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Sign in to create and join emergency plans.")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // The Apple Sign In Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    // This is part of the security protocol
                    let nonce = viewModel.randomNonceString()
                    viewModel.currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewModel.sha256(nonce)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        // Pass the credentials to the ViewModel
                        Task {
                            let (user, error) = await viewModel.handleSignIn(authResults: authResults)
                            
                            // If successful, tell the main AuthService
                            if let user = user {
                                await authService.handleSignInSuccess(user: user)
                            } else if let error = error {
                                // TODO: Show an alert
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("Apple Sign In failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 55)
            .cornerRadius(12)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}