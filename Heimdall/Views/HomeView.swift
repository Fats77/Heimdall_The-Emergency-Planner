//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//

import SwiftUI

struct HomeView: View {
    
    let columns: [GridItem] = [
        GridItem(.flexible()) , GridItem(.flexible()) ,GridItem(.flexible())
    ]
    let contactColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 120)),
    ]
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                HStack(){
                    Text( "Hello, Imma")
                        .bold()
                        .padding()
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                      //  .padding(.trailing, 16)
                }
                .padding(.trailing, 16)
                .padding(.horizontal,10)
               // .border(.black,width: 2)
               // .padding(.horizontal,10)
                LazyVGrid(columns: columns) {
                    ForEach(1...6, id: \.self) { item in
                        Text("Plan \(item)")
                            .frame(width: 120, height: 200)
                            .background(.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.5),radius: 5)
                    }
                }
                .padding()
                HStack(spacing: 8) {
                    Text("Personal Emergency Contacts")
                        .bold()
                    Image(systemName: "phone.fill")
                        .imageScale(.large)
                        
                }
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: contactColumns, alignment: .leading) {
                    ForEach(["fruit", "car", "plane swift"], id: \.self) { item in
                        Text("Contact for \(item)")
                            .lineLimit(1) // Allow text to wrap if needed
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.5),radius: 5)
                    }
                }
                .padding()
                HStack(spacing: 10) {
                    Text("History")
                        .bold()
                    Image(systemName: "clock.fill")
                        .imageScale(.large)
                }
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(1...6, id: \.self)
                    {
                        index in
                        Text("A List Item")
                            .frame(maxWidth: .infinity , alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.5),radius: 5)
                            .contextMenu{
                                Button("Delete") {}
                                
                            }
                    }
                    
                   
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
        
        
    }
    
}
#Preview {
    HomeView()
}
