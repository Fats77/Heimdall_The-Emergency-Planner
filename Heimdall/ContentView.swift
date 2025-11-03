//
//  ContentView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var body: some View {
        if isOnboarding {
            OnboardingView()
        } else {
            TabView {
                Tab ( "Overview", systemImage: "bolt"){
                    HomeView()
                }
                Tab ("Sccan" , systemImage: "qrcode.viewfinder"){
                    AttendanceView()
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
