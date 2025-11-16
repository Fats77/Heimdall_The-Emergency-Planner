//
//  ChecklistCardView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI
private let accentColor = Color(red: 0.23, green: 0.59, blue: 0.59)

struct ChecklistCardView: View {
    var isSafe : Bool? = true
    @State private var showEmergencySheet = false
    @State private var selectedContact: String? = nil
    @State private var showCallAlert = false
    @State private var showCopyToast = false
    
    let contacts = [
        "Father": "+1 234 567 8901",
        "Mom": "+1 987 654 3210",
        "Jinny": "+1 555 123 4567"
    ]

    var body: some View {
            HStack(alignment: .top){
                Image(.profilePlaceholder)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius:3))
                    .frame(width: 80, height: 80)
                    .padding(.trailing)
                //  .shadow(color: Color.tertiary .opacity(0.2), radius: 5, x: -2, y: 7)
                
                HStack {
                    VStack(alignment: .leading){
                        
                        Text("Imma ")
                            .font(.title3)
                            .bold()
                        
                        Text("Member")
                            .opacity(0.7)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                    
                    
                    if isSafe == true
                    {
                        HStack{
                            
                        }
                        Text ("SAFE")
                            .foregroundStyle(Color.safe)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(.green.opacity(0.2)).stroke(Color.safe, lineWidth: 1))
                    }
                    else if isSafe == false {
                        Text ("Missing")
                            .font(.caption2)
                            .foregroundStyle(Color.red)
                            .fontWeight(.semibold)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.primary2.opacity(0.1)).stroke(Color.primary2, lineWidth: 1))
                    }else{
                        Button{
                            
                        }
                    label:
                        {
                            CustomButtonView(label: "Check", symbol: "person.fill.checkmark", type: 1)
                            
                        }
                    }
                    
                    if isSafe != nil
                    {
                        Button {
                            showEmergencySheet = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundStyle(Color.tertiary)
                                .bold()
                        }
                        .sheet(isPresented: $showEmergencySheet) {
                            VStack(spacing: 20) {
                                Text("Emergency Contacts")
                                    .font(.headline)
                                    .padding(.top)
                                
                                Divider()
                                
                                ForEach(contacts.sorted(by: { $0.key < $1.key }), id: \.key) { contact, number in
                                    EmergencyContactListView(showCopyToast: $showCopyToast, showCallAlert: $showCallAlert, contact: contact, number: number)
                                }
                                
                                Spacer()
                            }
                            .overlay(
                                Group {
                                    if showCopyToast {
                                        Text("Number copied to clipboard")
                                            .font(.subheadline.bold())
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 16)
                                            .font(.footnote.bold())
                                            .background(Color.black.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .transition(.move(edge: .bottom).combined(with: .opacity))
                                            .onAppear {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    withAnimation(.easeInOut) {
                                                        showCopyToast = false
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 20)
                                            .allowsHitTesting(false)
                                    }
                                }, alignment: .bottom
                            )
                            .presentationDetents([.medium])
                            .background(Color(UIColor.systemBackground))
                            .overlay(
                                Group {
                                    if showCallAlert {
                                        Color.black.opacity(0.4)
                                            .ignoresSafeArea()
                                            .onTapGesture { showCallAlert = false }
                                            .transition(.opacity)
                                        VStack(alignment: .leading,spacing: 16,) {
                                            Text("Would you like to call this contact?")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(selectedContact ?? "")
                                            
                                                .foregroundColor(Color.tertiary)
                                                .opacity(0.7)
                                            HStack(spacing: 12) {
                                                Spacer()
                                                CustomButtonView(label: "Cancel", symbol: "xmark", type: 2)
                                                
                                                    .onTapGesture {
                                                        // Future call integration
                                                        showCallAlert = false
                                                    }
                                                CustomButtonView(label: "Call", symbol: "phone.fill", type: 1)
                                                    .onTapGesture { showCallAlert = false
                                                    }
                                            }
                                        }
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
                                        .shadow(radius: 10)
                                        .padding(40)
                                        .transition(.opacity)
                                    }
                                }
                                .animation(.easeInOut, value: showCallAlert)
                            )
                        }
                    }
                    
                }
                .padding(.top, 7)
                
                
                // .padding()
            }
            
            .padding()
            .dynamicTypeSize(...DynamicTypeSize.xLarge)
        
            .background{
                Color.white
                    
            }
        
            .clipShape(RoundedRectangle(cornerRadius: 10))
            //.shadow(color: Color.tertiary .opacity(0.6), radius: 5, x: 0, y:2)
        
    }
        
}

#Preview {
    ChecklistCardView(isSafe: false)
}
