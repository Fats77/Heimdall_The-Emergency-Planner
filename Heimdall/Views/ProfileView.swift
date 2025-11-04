//
//  ProfileView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 02/11/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var body: some View {
        NavigationStack {
            VStack(){
                Button{
                    
                }
                label :
                {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                       // .foregroundStyle(Color.gray)
                        .fontWeight(.bold)
                        .shadow(color: .gray.opacity(0.9),radius: 9)
                    
                }
                Text( "Hello, Imma")
                    .font(.title)
                    .padding()
                Text ("imma323.33@gmail.com")
                
                   
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            
            .if(colorScheme == .dark, transform: { view in
                view.tint(Color.white)
            })
            .if(colorScheme != .dark, transform: { view in
                view.tint(Color.black)
            })
            
            List {
                NavigationLink
                {
                    HomeView()
                }label:
                {
                    Text("A Second List Item")
                    
                }
                
                NavigationLink
                {
                    HomeView()
                }label:
                {
                    Text("A Second List Item")
                    
                }
                
                NavigationLink
                {
                    HomeView()
                }label:
                {
                    Text("A Second List Item")
                    
                }
                NavigationLink
                {
                    HomeView()
                }label:
                {
                    Text("A Second List Item")
                    
                }
            
                
                
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
            }
        }
        


#Preview {
    ProfileView()
}
