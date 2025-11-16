//
//  CustomDayTimeView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 02/11/25.
//

import SwiftUI

struct CustomDayTimeView: View {
    @State var selectedDay = Calendar.current.component(.day, from: Date())
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTime = Date()
    
    var body: some View {
        let dynamicHStack = dynamicTypeSize > .large ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
        dynamicHStack{
            HStack{
                Text("Day")
                   
                Picker(selection: $selectedDay, label: Text("Day Picker"))
                {
                    ForEach(1...31, id: \.self) {
                        date in
                        Text("\(date)")
                        
                    }
                }
                .background(PrimaryGradientView())
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .pickerStyle(.menu)
          
                .if(colorScheme == .dark, transform: { view in
                    view.tint(Color.white)
                })
                .if(colorScheme != .dark, transform: { view in
                    view.tint(Color.white)
                })
                
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            
            .frame(maxWidth: .infinity, alignment: .leading)
            //.background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            HStack{
                if dynamicTypeSize <= .large{
                    Spacer()
                }
                
                Text("Time")
                 //   .dynamicTypeSize(...DynamicTypeSize.accessibility1)
               
                ZStack {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .colorMultiply(.clear)
                        .blendMode(.destinationOver)
                    Text(selectedTime, style: .time)
                        .foregroundColor(.white)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                .background(PrimaryGradientView())
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
        .padding()
    }
}

#Preview {
    CustomDayTimeView()
}
