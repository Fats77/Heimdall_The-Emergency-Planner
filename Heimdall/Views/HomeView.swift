//
//  HomeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 24/10/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State private var showAddContactSheet = false
    let columns: [GridItem] = [
        GridItem(.flexible()) , GridItem(.flexible()) ,GridItem(.flexible())
    ]
    
    let contactColumns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                //MARK: Header Overview
                HStack{
                    Text("Hello, Imma")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                }
                .padding(.horizontal)
                .padding(.vertical,5)
                
                //MARK: Drill Plans Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Existing Drill Plans")
                            .font(.title3.bold())
                            .foregroundColor(Color.primary)
                        Spacer()
//                        Button {
//
//                        } label: {
//                            Text("New")
//                                .fontWeight(.semibold)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
//                                .background(Color.accentColor)
//                                .clipShape(Capsule())
//                        }
                     
                        CustomButtonView(label: "Add New",symbol: "plus",type: 1,)
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                    
                    //MARK: Drill Cards
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(1...6, id: \.self) { item in
                            Text("Plan \(item)")
                                .frame(width: 100, height: 150)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(0.8), Color(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .foregroundStyle(Color.primary)
                                .cornerRadius(12)
                                .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                        }
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                
                //MARK: Emergency Contacts
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone")
                            .imageScale(.large)
                        Text("Personal Emergency Contact")
                            .font(.title3.bold())
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    
                    //MARK: Emergency Contact List
                    LazyVGrid(columns: contactColumns, alignment: .leading, spacing: 10) {
                        ForEach(["fruit", "car", "plane swift"], id: \.self) { item in
                            Text("Contact for \(item)")
                                .lineLimit(1)
//                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(Color.primary)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        Button {
                            showAddContactSheet = true
                        }
                        label: {
                            HStack() {
                                Text("Add New")
                                Image(systemName: "plus")
                            }
                        }
                        .accessibilityLabel(Text("Add New Emergency Contact"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(PrimaryGradientView())
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
               // .padding(.vertical, 8)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                //MARK: History Section Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "clock")
                            .imageScale(.large)
                        Text("History")
                            .font(.title3.bold())
                    }
                    .padding(.leading, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    //MARK: History List
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(1...6, id: \.self) { index in
                            Text("A List Item")
                                .frame(maxWidth: .infinity , alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                                .foregroundStyle(Color.primary)
                                .background(Color(.systemBackground))
                            
                                .cornerRadius(12)
                             //   .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                                .contextMenu{
                                    Button("Delete") {}
                                }
                            Divider()
                               
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
              //  .shadow(color: Color.tertiary .opacity(0.4), radius: 5, x: -2, y: 7)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            }

            .background(Color(.systemGroupedBackground))
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $showAddContactSheet) {
            VStack(spacing: 20) {
                Text("Add Emergency Contact")
                    .font(.title2.bold())
                    .padding(.top)
                
                TextField("Name", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Phone Number", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                Button("Save Contact") {
                    // future save functionality
                    showAddContactSheet = false
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(PrimaryGradientView())
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
#Preview {
    HomeView()
}
