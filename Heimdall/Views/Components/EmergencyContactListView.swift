//
//  EmergencyContactListView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 13/11/25.
//

import SwiftUI


struct EmergencyContactListView: View {
    @Binding var showCopyToast : Bool
    @Binding var showCallAlert : Bool
    @State var selectedContact : String = ""
    let contact : String
    let number : String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(contact)
                    .font(.headline)
                    
                Text(number)
                    .font(.subheadline)
                  //  .foregroundColor(.gray)
                    .foregroundStyle(Color.tertiary)
                    .opacity(0.7)
            }
            Spacer()
            Button {
                UIPasteboard.general.string = number
                withAnimation(.easeInOut) {
                    showCopyToast = true
                }
            } label: {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(Color.tertiary)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Copy phone number for \(contact)")
            .accessibilityHint("Copies the phone number \(number) to clipboard")
            
            Button {
                selectedContact = contact
                showCallAlert = true
            } label: {
                Image(systemName: "phone.fill")
                    .foregroundColor(Color.tertiary)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Call \(contact)")
            .accessibilityHint("Initiates a call to \(contact)")
        }
        .padding(.horizontal)
    }
}

#Preview {
    EmergencyContactListView(showCopyToast: .constant(true), showCallAlert: .constant(true), selectedContact: "00012324384324", contact: "Father Dojo", number: "324234343")
}
