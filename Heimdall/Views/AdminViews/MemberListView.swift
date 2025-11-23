//
//  MemberListView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 11/11/25.
//

//import SwiftUI
//
//struct MemberListView: View {
//
//    @State private var searchText = ""
//    @State private var showMemberDetail: Bool = false
//    @State var showCopyToast: Bool = false
//    @State var showCallAlert: Bool = false
//    var selectedContact : String = ""
//    
//    @State private var members: [Member] = [
//        Member(name: "John Doe", role: "Admin", imageName: "person.circle.fill"),
//        Member(name: "Emma Watson", role: "Coordinator", imageName: "person.circle.fill"),
//        Member(name: "Ali Khan", role: "Member", imageName: "person.circle.fill")
//    ]
//    
//    let contacts = [
//        "Father": "+1 234 567 8901",
//        "Mom": "+1 987 654 3210",
//        "Jinny": "+1 555 123 4567"
//    ]
//
//    var filteredMembers: [Member] {
//        if searchText.isEmpty { return members }
//        return members.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Apple Building New Wings")
//                        .font(.title).bold()
//                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
//                        .padding()
//                    
//                    
//                    // Search Bar
//                    HStack{
//                        Image(systemName: "magnifyingglass")
//                        TextField("Search members...", text: $searchText)
//                    }
//                    
//                        .padding()
//                        .background(Color.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
////                        .overlay(
////                                RoundedRectangle(cornerRadius: 15)
////                                    .stroke(.gray, lineWidth: 1)
////                            )
//                        .padding(.horizontal)
//                        
//                    Text("Member List")
//                        .padding(.top)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                        .padding(.horizontal, 15)
//                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        
//                    
//                    // Member List
//                    LazyVStack(spacing: 6) {
//                        ForEach(filteredMembers) { member in
//                            Button{
//                                showMemberDetail = true
//                            }label: {
//                                MemberCardView(member: member)
//                                
//                            }
//                            .tint(.black)
//                        }
//                    }
//                    .padding(.top)
//                }
//                .padding(8)
//                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
//                .sheet(isPresented: $showMemberDetail) {
//                    VStack(spacing: 20){
//                        Text("Emergency Contact")
//                            .font(.headline)
//                            .padding(.top)
//                        Divider()
//                        ForEach(contacts.sorted(by: { $0.key < $1.key }), id: \.key) { contact, number in
//                            
//                            EmergencyContactListView(showCopyToast: $showCopyToast, showCallAlert: $showCallAlert, contact: contact, number: number)
//                        }
//                        Spacer()
//                    }.padding()
//                    .frame(maxHeight:.infinity)
//                    .overlay(
//                        Group {
//                            if showCopyToast {
//                                Text("Number copied to clipboard")
//                                    .font(.subheadline.bold())
//                                    .padding(.vertical, 10)
//                                    .padding(.horizontal, 16)
//                                    .background(PrimaryGradientView())
//                                    .foregroundColor(.white)
//                                    .cornerRadius(12)
//                                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                                    .onAppear {
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                            withAnimation(.easeInOut) {
//                                                showCopyToast = false
//                                            }
//                                        }
//                                    }
//                                    .padding(.bottom, 20)
//                                    .allowsHitTesting(false)
//                            }
//                        }, alignment: .bottom
//                    )
//                    .presentationDetents([.medium])
//                    .background(Color(UIColor.systemBackground))
//                    .overlay(
//                        Group {
//                            if showCallAlert {
//                                Color.black.opacity(0.4)
//                                    .ignoresSafeArea()
//                                    .onTapGesture { showCallAlert = false }
//                                    .transition(.opacity)
//                                VStack(alignment: .leading,spacing: 16,) {
//                                    Text("Would you like to call this contact?")
//                                        .font(.headline)
//                                        .foregroundColor(.primary)
//                                    Text(selectedContact ?? "")
//                                    
//                                        .foregroundColor(Color.tertiary)
//                                        .opacity(0.7)
//                                    HStack(spacing: 12) {
//                                        Spacer()
//                                        CustomButtonView(label: "Cancel", symbol: "xmark", type: 2)
//                                        
//                                            .onTapGesture {
//                                                // Future call integration
//                                                showCallAlert = false
//                                            }
//                                        CustomButtonView(label: "Call", symbol: "phone.fill", type: 1)
//                                            .onTapGesture { showCallAlert = false
//                                            }
//                                    }
//                                }
//                                .padding()
//                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
//                                .shadow(radius: 10)
//                                .padding(40)
//                                .transition(.opacity)
//                            }
//                        }
//                        .animation(.easeInOut, value: showCallAlert)
//                    )
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//        }
//    }
//}
//
//#Preview {
//   MemberListView()
//}
//
//struct MemberCardView : View {
//    var member: Member
//    @State private var adminToggle = false
//    @State private var coordinatorToggle = false
//    @State private var selectedRole = "Member"
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: member.imageName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 50, height: 50)
//                .foregroundColor(.black)
//                .clipShape(Circle())
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(member.name)
//                    .font(.headline)
//                Text(member.role)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            Menu {
//                Section("Role"){
//                    Toggle(
//                       "Make Admin",
//                       isOn: Binding(
//                           get: { selectedRole == "Admin" },
//                           set: { newValue in
//                               if newValue {
//                                   selectedRole = "Admin"
//                               } else {
//                                   selectedRole = "Member"
//                               }
//                           }
//                       )
//                   )
//                   
//                   Toggle(
//                       "Make Coordinator",
//                       isOn: Binding(
//                           get: { selectedRole == "Coordinator" },
//                           set: { newValue in
//                               if newValue {
//                                   selectedRole = "Coordinator"
//                               } else {
//                                   selectedRole = "Member"
//                               }
//                           }
//                       )
//                   )
//                }
//                .padding(.vertical)
//                
//                
//                Divider()
//                
//                Button("Remove Member", role: .destructive) {
//                    // Implement action to remove member
//                }
//            } label: {
//                Image(systemName: "ellipsis")
//                    .foregroundColor(.gray)
//                    .font(.title3)
//                    .rotationEffect(.degrees(90))
//            }
//            .menuActionDismissBehavior(.disabled)
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
//        .padding(.horizontal)
//    }
//}
