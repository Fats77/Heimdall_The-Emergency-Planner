//
//  AttendanceView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI
import UIKit // Needed for copy-to-clipboard

struct AttendanceView: View {
    
    // We pass these in from the previous screen
    let buildingID: String
    let eventID: String
    let eventName: String
    
    @StateObject private var viewModel: AttendanceViewModel
    
    // For the copy-to-clipboard toast
    @State private var showCopyToast = false
    
    init(buildingID: String, eventID: String, eventName: String) {
        self.buildingID = buildingID
        self.eventID = eventID
        self.eventName = eventName
        _viewModel = StateObject(wrappedValue: AttendanceViewModel(
            buildingID: buildingID,
            eventID: eventID
        ))
    }
    
    var body: some View {
        List {
            // --- 1. Summary Info Section (Your New Feature) ---
            Section {
                HeaderSummaryView(
                    total: viewModel.totalCount,
                    safe: viewModel.safeCount,
                    inProgress: viewModel.inProgressCount
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // --- 2. Unchecked / Missing Section ---
            Section(header: Text("Missing / In Progress (\(viewModel.inProgressAttendees.count))")) {
                if viewModel.inProgressAttendees.isEmpty && !viewModel.searchText.isEmpty {
                    Text("No results for \"\(viewModel.searchText)\"")
                } else if viewModel.inProgressAttendees.isEmpty {
                    Text("No one is missing.")
                }
                
                ForEach(viewModel.inProgressAttendees) { attendee in
                    ChecklistCardView(
                        attendee: attendee,
                        onManualCheckIn: {
                            viewModel.manualCheckIn(attendee: attendee)
                        }
                    )
                    // Feature 6: Call/Copy Menu
                    .contextMenu {
                        Button {
                            call(number: attendee.phone)
                        } label: {
                            Label("Call \(attendee.name)", systemImage: "phone")
                        }
                        
                        Button {
                            copy(number: attendee.phone)
                        } label: {
                            Label("Copy Number", systemImage: "doc.on.doc")
                        }
                    }
                }
            }
            
            // --- 3. Checked / Safe Section ---
            Section(header: Text("Safe (\(viewModel.safeAttendees.count))")) {
                ForEach(viewModel.safeAttendees) { attendee in
                    ChecklistCardView(attendee: attendee, onManualCheckIn: nil)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(eventName)
        // Feature 4 & 5: Toolbar Buttons
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.exportToExcel()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button(role: .destructive) {
                    viewModel.stopEvent()
                    // TODO: Should probably show a confirmation alert here
                } label: {
                    Text("Stop")
                }
            }
        }
        // Feature: Search Bar
        .searchable(text: $viewModel.searchText)
        .background(Color.theme.opacity(0.1))
        .overlay(
            Group {
                if showCopyToast {
                    Text("Phone number copied!")
                        .font(.footnote.bold())
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .padding(.bottom, 20)
                }
            },
            alignment: .bottom
        )
    }
    
    // --- Helper functions for Call/Copy ---
    private func call(number: String?) {
        guard let phoneNumber = number,
              let url = URL(string: "tel://\(phoneNumber.filter(\.isNumber))") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func copy(number: String?) {
        guard let phoneNumber = number else { return }
        UIPasteboard.general.string = phoneNumber
        
        // Show toast
        withAnimation {
            showCopyToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopyToast = false
            }
        }
    }
}

// --- Your New Summary View ---
struct HeaderSummaryView: View {
    let total, safe, inProgress: Int
    
    var body: some View {
        HStack {
            SummaryItem(count: total, label: "Total")
            SummaryItem(count: safe, label: "Safe", color: .green)
            SummaryItem(count: inProgress, label: "Missing", color: .red)
        }
        .padding()
    }
    
    struct SummaryItem: View {
        let count: Int
        let label: String
        var color: Color = .primary
        
        var body: some View {
            VStack {
                Text("\(count)")
                    .font(.title.bold())
                    .foregroundColor(color)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
#Preview {
//    AttendanceView()
}
