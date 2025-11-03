//
//  ChecklistCardView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI

struct ChecklistCardView: View {
    var isSafe : Bool? = true
    var body: some View {
        HStack(alignment: .top){
            Image(.profilePlaceholder)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius:3))
                .frame(width: 80, height: 80)
                .padding(.trailing)
                
            HStack {
                VStack(alignment: .leading){
                    
                    Text("Imma 🐣 ")
                        .font(.title3)
                        .bold()
                    
                    Text("Member")
                        .bold()
                        .foregroundStyle(.black.opacity(0.6))
                }
                
                Spacer()
                

                if isSafe == true
                {
                    Text ("SAFE")
                        .foregroundStyle(Color.safe)
                        .fontWeight(.semibold)
                        .padding(3)
                }
                else if isSafe == false {
                    Text ("SOS")
                        .foregroundStyle(Color.red)
                        .fontWeight(.semibold)
                        .padding(3)
                }else{
                    Button{
    
                    }
                    label:
                    {
                        Text("Check")
                        Image(systemName: "person.fill.checkmark")
    
                    }
                    .foregroundStyle(Color.black)
                    .padding(10)
                    .background(Capsule().fill(.white))
                }
                
                if isSafe != nil
                {
                    Menu {
                        Section ("Emergency Contacts")
                        {
                            
                            Text("Fire Fighter")
                            Text("Ambulance")
                            Text("Mom")
                              
                        }
                       
                    }
                    
                    label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(Color.black)
                            .bold()
                          
                    }
                }
                
            }
            .padding(.top, 7)
            
            
           // .padding()
        }
        .padding()
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .background{
            Color.gray.opacity(0.2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
        
}

#Preview {
    ChecklistCardView(isSafe: nil)
}
