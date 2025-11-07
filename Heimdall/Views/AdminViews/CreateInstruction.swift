//
//  CreateInstruction.swift
//  Heimdall
//
//  Created by Fatima Zeb on 01/11/25.
//

import SwiftUI

struct CreateInstruction: View {
    @State private var emergencyType =  "Pick Emergency"
    @State private var drillDuraion = "Select Duration"
    let emergencyData = ["Pick Emergency", "Earthquake", "Fire", "Tsunami"]
    let drillDurations  = [
        "Select Duration" , "Monthly" , "Quaterly" , "Annually"
    ]
    
    var body: some View {
       
        ScrollView{
            
            VStack (spacing: 3){
                
                Text("Emergency Type")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .font(.title2)
                    .bold()
                    
                
                HStack {
                    Picker("Pick Emergency", selection: $emergencyType) {
                        ForEach (emergencyData, id: \.self )
                        {
                            emergency in
                            Text(emergency)
                            
                            
                        }
                        
                    }
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .tint(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
//                    .shadow(color: .black.opacity(0.5),radius: 5)
                    
                }
                .foregroundStyle(Color.black)
                .padding()
                
                    Text ("Schedule")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .font(.title2)
                        .bold()
                VStack (alignment: .leading){
                    Picker("Pick Duration", selection: $drillDuraion) {
                        ForEach (drillDurations, id: \.self )
                        {
                            item in
                            Text(item)
                                
                        }
                        
                    }
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
//                    .background(.white)
                    .cornerRadius(8)
                 //   .shadow(color: .black.opacity(0.5),radius: 5)
                    
                    .tint(.black)
                 CustomDayTimeView()
                               
                }
                .padding()
            }
            
        }
        
    }
}

#Preview {
    CreateInstruction()
}
