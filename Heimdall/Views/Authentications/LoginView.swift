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
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    var body: some View {
        
        VStack{
            GeometryReader{ geo in
                Image(.authBG)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 500)
                    .clipped()
                
                Button{
                    withAnimation{
                        isOnboarding = true
                    }
                }label:{
                    HStack{
                        Image(systemName: "chevron.left")
                        Text("Onboarding")
                    }
                }
                .tint(.white)
                .underline()
                .position(x: 70, y: 70)
                
                Image(.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .position(x: geo.size.width / 2, y: geo.size.height / 2.7)
                    .shadow(radius: 30)
                
                VStack{
                    Text("Welcome")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Please sign in before continue")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
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
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.vertical, 30)
                .padding(.bottom, 80)
//                .background(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 50))
                .position(x: geo.size.width / 2, y: geo.size.height / 1.3)
            }
            
            Spacer()
                
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

