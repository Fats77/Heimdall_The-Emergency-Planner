//
//  OnboardingView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    let onboardingItemViews = [
        [
            "","",""
        ],
        [
            "Emergency Alerts",
            "Receive instant notifications for emergencies and critical situations in your area",
            "exclamationmark.triangle"
        ],
        [
            "Safety Drills",
            "Schedule and participate in regular emergency preparedness drills with your team",
            "calendar"
        ],
        [
            "Response Plans",
            "Access detailed evacuation routes and emergency protocols for any situation",
            "mappin"
        ],
    ]
    
    let iconBackgrounds = [
        [
            Color.red,
            Color.orange
        ],
        [
            Color.red,
            Color.orange
        ],
        [
            Color.purple,
            Color.blue
        ],
        [
            Color.blue,
            Color.cyan
        ],
    ]
    
    var body: some View {
        GeometryReader { geo in
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingItemViews).enumerated(), id: \.offset) { index, onboardingItem in
                    OnboardingItemView(title: onboardingItem[0], description: onboardingItem[1], geometry: geo, iconBackgrounds: iconBackgrounds[index], symbol: onboardingItem[2], index: index, currentPage: $currentPage, maxOnboardingItem: onboardingItemViews.count
                    )
                    .tag(index)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    HStack(spacing: 8) {
                        ForEach(0...onboardingItemViews.count - 1, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.secondary2 : Color.gray.opacity(0.3))
                                .frame(width: index == currentPage ? 30 : 8,
                                       height: index == currentPage ? 8 : 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    HStack (alignment: .center, spacing: 10){
                        if currentPage > 0 {
                            Button{
                                withAnimation {
                                    currentPage -= 1
                                }
                            }label: {
                                CustomButtonView(label: "Back", fillWidth: true, type: 2)
                            }
                        }
                        
                        if currentPage < onboardingItemViews.count - 1 && currentPage >= 0 {
                            Button{
                                withAnimation {
                                    currentPage += 1
                                }
                            }label: {
                                CustomButtonView(label: "Continue", fillWidth: true)
                            }
                        } else {
                            Button{
                                isOnboarding = false
                            } label: {
                                CustomButtonView(label: "Get Started", fillWidth: true)
                            }
                        }
                    }
                    
                    .padding()
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}

struct OnboardingItemView: View {
    let title: String
    let description: String
    let geometry: GeometryProxy
    let iconBackgrounds: [Color]
    let symbol: String
    let index: Int
    @Binding var currentPage: Int
    let maxOnboardingItem: Int
    
    var body: some View{
        VStack{
            if index > 0 {
                Image(systemName: symbol)
                    .font(.system(size:60))
                    .frame(width: 150, height: 150)
                    .background{
                        LinearGradient(gradient: Gradient(colors: [iconBackgrounds[0], iconBackgrounds[1]]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: Color.tertiary.opacity(0.8), radius: 20, y: 10)
                    .padding(.top, -100)
                    .padding(.bottom)
                    .foregroundStyle(Color.white)
                
                Text(title)
                    .multilineTextAlignment(.center)
                    .kerning(2.0)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .opacity(0.7)
                    .font(.title3)
                    .frame(width: geometry.size.width / 1.2)
                    .padding(.top)
            } else {
                Image(.icon)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.tertiary.opacity(0.8), radius: 20, y: 10)
                    .padding(.top, -100)
                
                Text("Heimdall")
                    .kerning(2.0)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Emergency Planner")
                    .opacity(0.5)
                    .font(.title2)
                
                Text("Your comprehensive disaster preparedness and emergency response platform. Train smarter, plan faster.")
                    .multilineTextAlignment(.center)
                    .opacity(0.7)
                    .font(.title3)
                    .frame(width: geometry.size.width / 1.2)
                    .padding(.top)
            }
        }
        .frame(maxHeight: .infinity)
        
    }
}

#Preview {
    OnboardingView()
}
