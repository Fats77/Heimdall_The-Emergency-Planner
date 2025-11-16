//
//  InstructionInputView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 12/11/25.
//

import SwiftUI

struct InstructionInputView: View {
    @State private var name : String = ""
    @State private var desc : String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Title")
                    .font(.headline)
                // .foregroundColor(.tertiary)
                
                TextField("Enter name here", text: $name)
                    .padding(12)
                //.foregroundColor(.tertiary).opacity(0.6)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Description")
                    .font(.headline)
                //    .foregroundColor(.tertiary)
                
                TextEditor(text: $desc)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .frame(minHeight: 100)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
            
            
        }
    }
    
}

#Preview {
    InstructionInputView()
}
