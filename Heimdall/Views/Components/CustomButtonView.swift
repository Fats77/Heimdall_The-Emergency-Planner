//
//  CustomButtonView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 27/10/25.
//

import SwiftUI

struct CustomButtonView: View {
    let label: String
    var symbol: String? = nil
    var body: some View {
        
        HStack{
            
            Text(label)
            if symbol != nil {
                Image(systemName: symbol ?? "")
                
            }
        }
       
            .padding(.vertical)
            .padding(.horizontal, 20)
            .background{
                PrimaryGradientView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .foregroundStyle(.white)
    }
}

#Preview {
    CustomButtonView(label: "Custom Text", symbol: "plus")
}
