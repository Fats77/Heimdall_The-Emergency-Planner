//
//  AuthenticationView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 09/11/25.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Button(action: {
            authManager.startSignInWithApple()
        }) {
            // We wrap the UIKit button to get the official Apple style
            SignInWithAppleButtonView()
                .frame(height: 55)
                .cornerRadius(10)
        }
        .padding(.horizontal, 30)
    }
}

struct SignInWithAppleButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        // Create the button with the style you want
        return ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // No update needed
    }
}

#Preview {
    AuthenticationView()
}
