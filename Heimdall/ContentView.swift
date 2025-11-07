//
//  ContentView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    init() {
        // Optional: Clear UITableView background if needed for older iOS/specific list styles
        UIDatePicker.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.secondary2]
    }
    var body: some View {
        if isOnboarding {
            OnboardingView()
        } else {
            TabView {
                Tab ( "Overview", systemImage: "bolt"){
                    HomeView()
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
