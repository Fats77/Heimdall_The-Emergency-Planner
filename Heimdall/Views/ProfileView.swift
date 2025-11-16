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
    @State private var name: String = ""
    @State private var email: String = ""
    
    //    private let accentColor = Color(red: 0.75, green: 0.03, blue: 0.18)
    private let accentColor = Color(red: 0.23, green: 0.59, blue: 0.59)
    
    var body: some View {
        
        let dynamicVStack = dynamicTypeSize > .xLarge ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
        let dynamicHStack = dynamicTypeSize > .xLarge ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(spacing: 12))
        
        NavigationStack {
            
            
            VStack(spacing: 20) {
                List {
                    
                    dynamicHStack(){
                        dynamicVStack{
                            ZStack {
                            
                                
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height:70)
                                //                                .clipShape(Circle())
                                    .padding(.bottom,10)
                                
                                  //  .foregroundStyle(Color.b)
                                
                                Image(systemName: "pencil").bold()
                                    .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
                                    .frame(width: 20,height: 20)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius:7))
                                    .overlay(RoundedRectangle(cornerRadius:7)
                                        .stroke(Color.black,lineWidth: 1)
                                    )
                                    .position(x:75,y:25)
                                  
                            }
                            .frame(width: 100)
//                            Button {
//                            
//                            } label: {
//                                CustomButtonView(label: "Upload", symbol: "square.and.arrow.up", fillWidth:
//                                                    dynamicTypeSize > .xLarge , type: 1)
//                                 
//                            }
                           
                        }
                       // .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 8){
                            Text ("Name")
                            TextField("Your Name Here", text: $name)
                            Text ("Email")
                            Text ("fatimazebtanoli6@gmail.com")
                            //                                .foregroundStyle(Color.black)
                                .tint(.secondary).font(.subheadline)
                        }
                        
                            //.padding()
                            .background(Color.white)
                        
                    }
                    Button {
                        
                    } label: {
                         CustomButtonView(label: "Update", fillWidth: true)
                    }
                        .accessibilityLabel("Save Changes")
                        .accessibilityHint("Tap to edit your profile information")
                  
                  
                    
                    //                        HStack(alignment: .top, spacing: 30) {
                    //                            Image(systemName: "person.crop.circle")
                    //                                .resizable()
                    //                                .scaledToFit()
                    //                                .frame(width: 100, height: 100)
                    //                                .clipShape(Circle())
                    //                                .overlay(
                    //                                    Circle()
                    //                                        .stroke(Color.secondary2, lineWidth: 4)
                    //                                )
                    //                            VStack(alignment: .leading, spacing: 8) {
                    //                                Text("Hello, Imma!!")
                    //                                    .font(.title2).bold()
                    //                                    .foregroundColor(.primary)
                    //
                    //
                    //                                Button {
                    //                                    // Edit Profile action
                    //                                } label: {
                    //                                    CustomButtonView(label: "Update", fillWidth: true)
                    //
                    //                                }
                    //                                .accessibilityLabel("Update")
                    //                                .accessibilityHint("Tap to edit your profile information")
                    //                            }
                    //
                    //
                    //                        }
                    //                        .padding()
                    //                        .frame(maxWidth: .infinity, alignment: .leading)
                    //                        .background(Color(.secondarySystemGroupedBackground))
                    ////                        .shadow(color: Color.secondary2.opacity(0.4), radius: 6, x: 0, y: 3)
                    //                        .cornerRadius(14)
                    //MARK: Account Section
                    Section(header: Text("Account")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            
                    ) {
                        NavigationLink {
                            HomeView()
                        } label: {
                            Label("Personal Information", systemImage: "person.fill")
                                .font(.body)
                            //  .foregroundColor(.tertiary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .accessibilityLabel("Personal Information")
                        .accessibilityHint("View and edit your personal information")
                        .frame(minHeight: 44)
                        
                        
                        
                        NavigationLink {
                            HomeView()
                        } label: {
                            Label("Change Password", systemImage: "key.fill")
                                .font(.body)
                            /// .foregroundColor(Color.tertiary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        }
                        //.shadow(color: accentColor.opacity(0.9), radius: 6, x: 0, y: 3)
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .accessibilityLabel("Change Password")
                        .accessibilityHint("Change your account password")
                        .frame(minHeight: 44)
                        
                    }
                    
                    
                    
                    // Preferences Section
                    Section(header: Text("Preferences")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                    ) {
                        NavigationLink {
                            HomeView()
                        } label: {
                            Label("Notifications", systemImage: "bell.fill")
                                .font(.body)
                            //   .foregroundColor(Color.tertiary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .accessibilityLabel("Notifications")
                        .accessibilityHint("Manage notification settings")
                        .frame(minHeight: 44)
                        
                        NavigationLink {
                            HomeView()
                        } label: {
                            Label("Privacy Settings", systemImage: "hand.raised.fill")
                                .font(.body)
                            //  .foregroundColor(Color.tertiary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .accessibilityLabel("Privacy Settings")
                        .accessibilityHint("Adjust your privacy preferences")
                        .frame(minHeight: 44)
                    }
                    
                    // More Section
                    Section(header: Text("More")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    ) {
                        NavigationLink {
                            HomeView()
                        } label: {
                            Label("Help & Support", systemImage: "questionmark.circle.fill")
                                .font(.body)
                                .foregroundColor(Color.primary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .accessibilityLabel("Help and Support")
                        .accessibilityHint("Get help and support information")
                        .frame(minHeight: 44)
                        
                        NavigationLink {
                            HomeView()
                        } label: {
                            Label("Log Out", systemImage: "arrow.right.square.fill")
                                .font(.body)
                                .foregroundColor(Color.primary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .accessibilityLabel("Log Out")
                        .accessibilityHint("Log out of your account")
                        .frame(minHeight: 44)
                    }
                }
                .listStyle(.insetGrouped)
                .foregroundStyle(.primary, .red)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .navigationTitle("Profile Settings")
            
            
            
        }
    }
    
}

#Preview {
    ProfileView()
}
