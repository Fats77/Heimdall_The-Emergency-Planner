//
//  ContentView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            Tab ( "Overview", systemImage: "bolt")
            {HomeView()}
            Tab ("Sccan" , systemImage: "qrcode.viewfinder")
            {
                AttendanceView()
            }
           
            
            
        }
    }
    
}

#Preview {
    ContentView()
}
