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
    var fillWidth: Bool = false
    
    /*
     Type guideline:
     1 -> Primary
     2 -> Secondary
     3 -> Tertiary
     */
    var type: Int = 2
    
    var isDisabled: Bool = false
    
    var body: some View {
        HStack{
            Text(label)
            if symbol != nil {
                Image(systemName: symbol ?? "")
            }
        }
        .if(fillWidth) { view in
            view.frame(maxWidth: .infinity)
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
        .background{
            if type == 1 {
                PrimaryGradientView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(type == 1 ? Color.white : type == 2 ? Color.tertiary : Color.black)
        .if(type == 3) { view in
            view.underline()
        }
    }
}

#Preview {
    CustomButtonView(label: "Custom Text", symbol: "plus")
}
