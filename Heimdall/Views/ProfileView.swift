//
//  ProfileView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 02/11/25.
//

import SwiftUI

struct ProfileView: View {
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
                        .foregroundStyle(Color.black)
                        .fontWeight(.bold)
                        .shadow(color: .gray.opacity(0.9),radius: 9)
                }
                Text( "Hello, Imma")
                    .font(.title)
                    .padding()
                Text ("imma323.33@gmail.com")
                    .tint(.black)
            }
            
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
        }
            }
        }
        


#Preview {
    ProfileView()
}
