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
    var type: Int = 1
    
    var isDisabled: Bool = false
    
    var body: some View {
        HStack{
            Text(label)
                .dynamicTypeSize(...DynamicTypeSize.large)
            if symbol != nil {
                Image(systemName: symbol ?? "")
            }
        }
        .if(fillWidth) { view in
            view.frame(maxWidth: .infinity)
        }
        .font(.body)
        .padding(.vertical,10)
        .padding(.horizontal, 12)
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .background {
            if type == 1 {
                PrimaryGradientView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay{
            if [1, 2].contains(type) {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.secondary2, .theme]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        ,lineWidth: 1
                    )
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
            }
        }
        .shadow(color: Color.tertiary .opacity(0.5), radius: 4, x: 0, y: 3)
        .foregroundStyle(type == 1 ? Color.white : type == 2 ? Color.secondary2 : Color.black)
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        
        .if(type == 3) { view in
            view.underline()
        }
    }
    
}

#Preview {
    CustomButtonView(label: "Custom Text", symbol: "plus")
}
