//
//  AttendanceView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI

struct AttendanceView: View {
    var body: some View {
        ScrollView{
            Text ("Unchecked (3)" )
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(1...3, id: \.self){ num in
                ChecklistCardView(isSafe: nil)
            }
            Spacer()
            Text ("Checked (7)")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(1...3, id: \.self)
            {
                number in ChecklistCardView(isSafe: number % 2==0)
            }
            
        }
        .padding()
       
    }
}

#Preview {
    AttendanceView()
}
