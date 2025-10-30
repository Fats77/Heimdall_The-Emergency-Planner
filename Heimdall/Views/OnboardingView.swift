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
        NavigationStack{
            
            VStack(alignment: .center){
               LandingScreenView()
            }
            
        }
    }
}

struct LandingScreenView: View {
    var body: some View {
        ZStack {
            GeometryReader{
                geo in
//                Rectangle()
//                    .fill(Color.theme)
//                    .frame(width: 600, height: 2000)
//                    .position(x: geo.size.width / 2, y: 10)
                
                Image(.helmet)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.tertiary.opacity(0.8), radius: 20, y: 10)
                    .position(x: geo.size.width / 2, y: geo.size.height / 3)
                
                Text("Heimdall")
                    .kerning(4.0)
                    .font(.title)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                Text("Emergency Planner")
                    .foregroundStyle(.white.opacity(0.5))
                    .font(.title2)
                    .position(x: geo.size.width / 2, y: geo.size.height / 1.85)
                
                Text("Your comprehensive disaster preparedness and emergency response platform")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.7))
                    .font(.title3)
                    .position(x: geo.size.width / 2, y: geo.size.height / 1.55)
                    .frame(width: geo.size.width / 1.2)
            }
        }
        .background{
            PrimaryGradientView()
        }
        .ignoresSafeArea()
        
    }
}

struct OnboardingItemView: View {
    var title: String
    var subtitle: String
    var description: String
    let index: Int
    
    var body: some View{
        VStack(alignment: .center, spacing: 10){
            
            Image(.helmet)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 150, height: 150)
                .padding(50)
                .shadow(color: .tertiary.opacity(0.7), radius:20, y: 10)

            Text(title)
                .font(.title)
                .foregroundStyle(Color.secondary2)
                .fontWeight(.bold)
            
            Text(subtitle)
                .foregroundStyle(.primary2)
                .font(.title2)
                .bold()
        
            Text(description)
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
