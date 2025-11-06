//
//  CreatePlan.swift
//  Heimdall
//
//  Created by Fatima Zeb on 30/10/25.
//

import SwiftUI

struct CreatePlan: View {
    let columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var descText: String = ""
    
    var nums = ["a", "b", "55"]
    
    private let accentColor = Color(red: 0.23, green: 0.59, blue: 0.59)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create Plan")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                        Text("Set up your next mission with clarity and precision.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Card container
                    VStack(spacing: 32) {
                        
                        // Select Icon Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Icon")
                                .font(.title2.bold())
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(Array(nums).enumerated(), id: \.offset) { index, num in
                                    ZStack (alignment: .center){
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.white,
                                                        Color(.systemGray5)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                           .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                           
                                        
                                        if index == nums.count - 1 {
                                            Button {
                                                // Add icon action
                                            } label: {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 28, weight: .bold))
                                                   .foregroundColor(.white)
                                                    .frame(width: geo.size.width / 6 - 12, height: geo.size.width / 6 - 12)
                                                    .background(accentColor)
                                                    .clipShape(Circle())
                                                   .shadow(color: accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                                            }
                                        } else {
                                            Image("BuildingPlaceholder-\(index)")
                                                .resizable()
                                                .scaledToFit()
                                              
                                        }
                                    }
                                    
                                    .frame(width: geo.size.width / 4.3, height: geo.size.width / 4.3)
                                    .background(accentColor)
                                    .clipShape(Circle())
                                   .shadow(color: accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Details")
                                .font(.title2.bold())
//                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Name")
                                    .font(.headline)
//                                    .foregroundColor(.primary)
                                
                                TextField("Enter name here", text: $descText)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Description")
                                    .font(.headline)
//                                    .foregroundColor(.primary)
                                
                                TextEditor(text: $descText)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .frame(minHeight: 100)
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Drill")
                                    //.padding()
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    // Upload map action
                                }) {
                                    HStack {
                                        Text("Upload the map")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "square.and.arrow.down")
                                            .font(.title2)
                                            .foregroundColor(accentColor)
                                    }
                                    .padding()
                                
                                    .background(colorScheme == .light ? Color.white : Color(.systemGray6))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(colorScheme == .dark ? Color.clear : Color.white)
                    .cornerRadius(20)
                    .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding()
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

#Preview {
    CreatePlan()
}
