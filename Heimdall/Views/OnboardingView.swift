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
        NavigationStack {
            GeometryReader{
                geo in
                VStack(alignment: .center) {
                    TabView(selection: $currentPage) {
                        LandingScreenView(geometry: geo)
                        
                        ForEach(1...2, id: \.self) { index in
                            LandingScreenView(geometry: geo)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        HStack(spacing: 8) {
                            ForEach(0...3, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? Color.secondary2 : Color.gray.opacity(0.3))
                                    .frame(width: index == currentPage ? 30 : 8,
                                           height: index == currentPage ? 8 : 8)
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                        
                        if currentPage < 3 && currentPage >= 0 {
                            Button{
                                if currentPage < 3 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                }
                            }label: {
                                CustomButtonView(label: "Next", fillWidth: true)
                                    .padding()
                            }
                        } else {
                            NavigationLink{
                                HomeView()
                            } label: {
                                CustomButtonView(label: "Start", fillWidth: true)
                                    .padding()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LandingScreenView: View {
    var geometry: GeometryProxy
    
    var body: some View {
        VStack{
            Image(.helmet)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .frame(width: 150, height: 150)
                .shadow(color: Color.tertiary.opacity(0.8), radius: 20, y: 10)
                .padding(.top, -100)
            
            Text("Heimdall")
                .kerning(4.0)
                .font(.title)
                .fontWeight(.bold)
            
            Text("Emergency Planner")
                .foregroundStyle(Color.black.opacity(0.5))
                .font(.title2)
            
            Text("Your comprehensive disaster preparedness and emergency response platform")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.black.opacity(0.7))
                .font(.title3)
                .frame(width: geometry.size.width / 1.2)
                .padding(.top)
        }
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
