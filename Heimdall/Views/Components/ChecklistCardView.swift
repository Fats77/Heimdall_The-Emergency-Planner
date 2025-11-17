//
//  ChecklistCardView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI
import Kingfisher // For loading profile images

struct ChecklistCardView: View {
    
    let attendee: Attendee
    var onManualCheckIn: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top) {
            // TODO: Load real profile image
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attendee.name)
                    .font(.title3)
                    .bold()
                
                Text(attendee.phone ?? "No phone number")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            // --- Status Logic ---
            if attendee.status == .safe {
                Text("SAFE")
                    .foregroundStyle(Color.green)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Capsule().fill(.green.opacity(0.2)).stroke(Color.green, lineWidth: 1))
            } else {
                // Feature 9: Manual Check-in Button
                Button {
                    onManualCheckIn?()
                } label: {
                    Text("Check In")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
//    ChecklistCardView(isSafe: false)
}
