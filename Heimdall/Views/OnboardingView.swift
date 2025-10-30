//
//  OnboardingView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var body: some View {
        
       
        VStack(alignment: .center, spacing: 10){
            
            Image(.helmet)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 150, height: 150)
                .padding(50)
                .shadow(color: .tertiary.opacity(0.7), radius:20, y: 10)

        Text("Welcome to Heimdall")
           // .font(.headline)
            .font(.title)
            .foregroundStyle(Color.secondary2)
            .fontWeight(.bold)
        Text("The Emergency Planner")
                .foregroundStyle(.primary2)
            .font(.title2)
            .bold()
    
        Text("Your comprehensive disaster preparedness and emergency response platform")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.tertiary)
                .font(.title3)
                .padding(.top,50)
        }
        .padding(40)
        
        
    }
}

#Preview {
    OnboardingView()
}
