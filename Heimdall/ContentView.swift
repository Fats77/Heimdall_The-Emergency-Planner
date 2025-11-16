//
//  ContentView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 23/10/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @EnvironmentObject var authManager: AuthManager
    
    init() {
        UIDatePicker.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.secondary2]
    }
    
    var body: some View {
        
        if authManager.userSession == nil || !authManager.isUserDataReady{
            AuthenticationView()
        } else {
            TabView {
                HomeView()
                    .environmentObject(authManager.firestoreManager)
                    .tabItem {
                        Label("Overview", systemImage: "bolt")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
