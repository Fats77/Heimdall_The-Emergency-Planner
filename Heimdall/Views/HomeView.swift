//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let columns: [GridItem] = [
        GridItem(.flexible()) , GridItem(.flexible()) ,GridItem(.flexible())
    ]
    let contactColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 120)),
    ]
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                //MARK: Header Overview
                HStack(){
                    Text( "Hello, Imma")
                        .font(.title)
                        .bold()
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                //MARK: Drill Plans Header
                VStack{
                    HStack()
                    {
                        Text("Existing Drill Plans")
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            CustomButtonView(label: "New" , symbol: "plus")
                        }
                        
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .padding(.horizontal)
                    //MARK: Drill Cards
                    LazyVGrid(columns: columns) {
                        ForEach(1...6, id: \.self) { item in
                            Text("Plan \(item)")
                                .frame(width: 120, height: 170)
                                .background(.white)
                                .foregroundStyle(Color.black)
                                .cornerRadius(8)
                        }
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                    .padding()
                }
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                .padding(.vertical)
                .background(Color.tertiary.opacity(0.3))
                //MARK: Emergency Contacts
                HStack(spacing: 8) {
                    Image(systemName: "phone")
                        .imageScale(.large)
                    Text("Personal Emergency Contacts")
                        .font(.title2)
                    //.scaleEffect(x:-1 , y:-1)
                    
                }
                .dynamicTypeSize(...DynamicTypeSize.xLarge)

                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                //MARK: Emergency Contact List
                LazyVGrid(columns: contactColumns, alignment: .leading) {
                    ForEach(["fruit", "car", "plane swift"], id: \.self) { item in
                        Text("Contact for \(item)")
                            .lineLimit(1) // Allow text to wrap if needed
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.black)
                            .background(.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.5),radius: 5)
                    }
                }
                //.dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                .padding()
                //MARK: History Section Header
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .imageScale(.large)
                    Text("History")
                        .font(.title2)
                    
                }
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                //MARK: History List
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(1...6, id: \.self)
                    {
                        index in
                        Text("A List Item")
                            .frame(maxWidth: .infinity , alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .foregroundStyle(Color.black)
                            .background(.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.5),radius: 5)
                            .contextMenu{
                                Button("Delete") {}
                                
                            }
                    }
                    
                    
                }
                .padding(.top)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            .navigationBarBackButtonHidden(true)
        }
        
        
        
    }
    
}
#Preview {
    HomeView()
}
