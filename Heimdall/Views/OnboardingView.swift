//
//  OnboardingView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Text("Heimdall")
                    .foregroundStyle(Color.tertiary)
                    .fontWeight(.heavy)
                    .font(.title)
                    .kerning(3.0)
                
                Text("Emergency Planner")
                    .foregroundStyle(Color.tertiary)
                    .font(.subheadline)
                
                VStack (alignment: .leading) {
                    NavigationLink{
                        
                    }label: {
                        VStack{
                            Text("Join a plan")
                        }
                    }
                    
                    NavigationLink{
                        
                    }label: {
                        VStack{
                            Text("Create new plan")
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
