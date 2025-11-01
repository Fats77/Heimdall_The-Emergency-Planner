//
//  CreateInstruction.swift
//  Heimdall
//
//  Created by Fatima Zeb on 01/11/25.
//

import SwiftUI

struct CreateInstruction: View {
    var body: some View {
       
        ScrollView{
            
            VStack (){
                
                Text("Emergency Type")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .font(.title)
                    .bold()
                
                HStack {
                    Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                        Text("Fire").tag(1)
                        Text("Earthquake").tag(2)
                    }
                    .foregroundStyle(.black)
                }
            }
            
            
        }
        
        
        
    }
}

#Preview {
    CreateInstruction()
}
