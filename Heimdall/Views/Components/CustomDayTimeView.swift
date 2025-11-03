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
    @State private var selectedTime = Date()
    
    var body: some View {
        let dynamicHStack = dynamicTypeSize > .large ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
        dynamicHStack{
            HStack{
                Text("Select Day")
                    Spacer()
                Picker(selection: $selectedDay, label: Text("Day Picker"))
                {
                    ForEach(1...31, id: \.self) {
                        date in
                        Text("\(date)")
                        
                    }
                }
               
                .background(.gray.opacity(0.2))
                .clipShape(Capsule())
                .pickerStyle(.menu)
                .tint(Color.black)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            //.background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            DatePicker(selection: $selectedTime, displayedComponents: .hourAndMinute, label: {
                /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/
            })
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .tint(.black)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
               // .background(Color.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}

#Preview {
    CustomDayTimeView()
}
