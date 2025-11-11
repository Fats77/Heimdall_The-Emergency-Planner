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
        if authManager.userSession == nil && isOnboarding{
            AuthenticationView()
        } else {
            TabView {
                Tab ( "Overview", systemImage: "bolt"){
                    HomeView()
                        .environmentObject(FirestoreManager(uid: authManager.userSession!.uid))
                }
                Tab ("Sccan" , systemImage: "qrcode.viewfinder"){
                    ProfileView()
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
