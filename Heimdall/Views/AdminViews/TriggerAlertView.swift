//
//  TriggerAlertView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import SwiftUI

struct TriggerAlertView: View {
    
    let building: Building
    let emergency: EmergencyType
    
    // This state tracks the "hold" progress
    @State private var isHolding = false
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var longPressGesture: some Gesture {
            LongPressGesture(minimumDuration: 3.0)
                .onChanged { inProgress in
                    // This fires when the hold *starts*
                    withAnimation { isHolding = true }
                }
                .onEnded { finished in
                    // This fires *only if* the hold completes (3 seconds)
                    if finished {
                        print("ALERT TRIGGERED!")
                        isHolding = false
                        Task {
                            await triggerAlert()
                            dismiss()
                        }
                    }
                }
        }
        
        // 2. The Drag Gesture (to detect finger lift)
        var dragGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onEnded { _ in
                    // This fires when the user lifts their finger
                    if isHolding {
                        print("Hold cancelled")
                        withAnimation { isHolding = false }
                    }
                }
        }
        
        // 3. The Combined Gesture
        var combinedGesture: some Gesture {
            // This is the fix: .simultaneously(with:)
            longPressGesture.simultaneously(with: dragGesture)
        }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            VStack {
                Text("Confirm Emergency Alert")
                    .font(.title2.bold())
                
                Text("You are about to alert all members in")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(building.name)
                    .font(.headline.bold())
            }
            
            // Warning Icon
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            // Details
            Text("EMERGENCY TYPE: \(emergency.prettyType.uppercased())")
                .font(.headline)
                .foregroundColor(.red)
            
            Text("This will send a high-priority push notification to all members.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // MARK: - The 3-Second Hold Button
            
            Text("Hold for 3 seconds to activate")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack {
                // The "track" of the button
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHolding ? .red.opacity(0.8) : .red.opacity(0.4))
                
                // The "label" that changes
                Text(isHolding ? "ACTIVATING..." : "HOLD TO ALERT")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .frame(height: 60)
            .padding(.horizontal)
            // This is the gesture that makes it all work
            .gesture(combinedGesture)
            // This modifier handles when the user lifts their finger *before* 3 seconds
//            .simultaneously(with: DragGesture(minimumDistance: 0)
//                .onEnded { _ in
//                    if isHolding {
//                        print("Hold cancelled")
//                        withAnimation {
//                            isHolding = false
//                        }
//                    }
//                }
//            )
            
            Button("Cancel") {
                dismiss()
            }
            .padding(.top, 10)
        }
        .padding(.top, 40)
    }
    
    /// This is the function that will call your Cloud Function
    func triggerAlert() async {
        isLoading = true
        let (success, message) = await EventService.shared.triggerAlert(
            building: building,
            emergency: emergency
        )
        
        isLoading = false
        
        if !success {
            // We can't show an alert here because the view is dismissing.
            // A better approach would be to have a global banner.
            // For now, we'll just print the error.
            print("Error triggering alert: \(message)")
        }
    }
}
