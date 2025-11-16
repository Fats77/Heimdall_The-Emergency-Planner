//
//  AttendanceView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI

struct AttendanceView: View {
    private let accentColor = Color(red: 0.23, green: 0.59, blue: 0.59)
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 8){
                Text ("Academy Attendence")
                    .font(.title).bold()
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .padding()
                Text ("Unchecked (3)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal,15)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                //                .padding()
                //                .font(.title3)
                //                .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(1...3, id: \.self){ num in
                    ChecklistCardView(isSafe: nil)
                    //  .dynamicTypeSize(...DynamicTypeSize.large)
                }
                Spacer()
                Text ("Checked (7)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal,15)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                //                .padding()
                //                .font(.title3)
                //                .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(1...3, id: \.self)
                {
                    number in ChecklistCardView(isSafe: number % 2==0)
                }
                
            }
            
            .padding(8)
            .ignoresSafeArea()
            
           
        }
       // .padding(6)
        .background(Color.theme.opacity(0.1))
        //.ignoresSafeArea()
        
       
    }
}

#Preview {
    AttendanceView()
}
