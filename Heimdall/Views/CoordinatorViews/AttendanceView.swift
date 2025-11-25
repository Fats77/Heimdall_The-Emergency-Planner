//
//  AttendanceView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 28/10/25.
//

import SwiftUI
import UIKit // For Copy/Call functionality
import Kingfisher // For profile images
import FirebaseFirestore

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
        VStack(spacing: 0) {
            // --- 1. Header and Summary Cards ---
            AttendanceSummaryView(viewModel: viewModel)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            // --- 2. Search Bar and Content ---
            List {
                // --- Missing / In Progress Members List ---
                Section(header: Text("MISSING / IN PROGRESS (\(viewModel.inProgressAttendees.count))")) {
                    if viewModel.inProgressAttendees.isEmpty && !viewModel.searchText.isEmpty {
                        Text("No Missing Members match \"\(viewModel.searchText)\"")
                    } else if viewModel.inProgressAttendees.isEmpty {
                        Text("All members accounted for.")
                    }
                    
                    ForEach(viewModel.inProgressAttendees) { attendee in
                        AttendeeCard(
                            attendee: attendee,
                            onManualCheckIn: { viewModel.manualCheckIn(attendee: attendee) }
                        )
                        .contextMenu(menuItems: { contactMenu(for: attendee) })
                    }
                }
                
                // --- Safe Members List ---
                Section(header: Text("SAFE MEMBERS (\(viewModel.safeAttendees.count))")) {
                    if viewModel.safeAttendees.isEmpty && !viewModel.searchText.isEmpty {
                        Text("No Safe Members match \"\(viewModel.searchText)\"")
                    } else if viewModel.safeAttendees.isEmpty {
                        Text("No one is marked safe yet.")
                    }
                    
                    ForEach(viewModel.safeAttendees) { attendee in
                        AttendeeCard(attendee: attendee, onManualCheckIn: nil)
                            .contextMenu(menuItems: { contactMenu(for: attendee) })
                    }
                }
            }
            .listStyle(.plain)
            // Feature 10: Search bar
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name or ID...")
            
            // --- 3. Bottom Action Buttons ---
            HStack(spacing: 12) {
                // Export/Send Report Button (CSV Export)
                Button {
                    viewModel.exportToExcel()
                } label: {
                    Text("Export Report (CSV)")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.theme)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                // Share Button (Shareable URL)
                Button {
                    let shareURL = "https://heimdall.app/report/\(eventID)"
                    shareAction(url: shareURL)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .padding(10)
                        .background(Color.theme.opacity(0.2))
                        .foregroundColor(.theme)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Attendance: \(eventName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    viewModel.stopEvent()
                } label: {
                    Text("Stop Alert")
                }
            }
        }
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
                        .padding(.bottom, 80)
                }
            },
            alignment: .bottom
        )
    }
    
    // MARK: - Menu Generation (Feature 6)
    @ViewBuilder
    private func contactMenu(for attendee: Attendee) -> some View {
        Button { call(number: attendee.phone) } label: { Label("Call \(attendee.name)", systemImage: "phone") }
        Button { copy(number: attendee.phone) } label: { Label("Copy Phone Number", systemImage: "doc.on.doc") }
    }
    
    // MARK: - Helper Actions
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
        
        withAnimation { showCopyToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showCopyToast = false }
        }
    }
    
    private func shareAction(url: String) {
        guard let shareURL = URL(string: url) else { return }
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Attendance Summary View
struct AttendanceSummaryView: View {
    @ObservedObject var viewModel: AttendanceViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            SummaryCard(
                count: viewModel.safeCount,
                label: "Safe",
                status: .safe,
                total: viewModel.totalCount
            )
            
            SummaryCard(
                count: viewModel.inProgressCount,
                label: "Missing",
                status: .missing,
                total: viewModel.totalCount
            )
            SummaryCard(
                count: viewModel.totalCount,
                label: "Total",
                status: .total,
                total: viewModel.totalCount
            )
        }
        .padding()
    }
    
    enum SummaryStatus { case safe, missing, total }
    
    struct SummaryCard: View {
        let count: Int
        let label: String
        let status: SummaryStatus
        let total: Int
        
        var color: Color {
            switch status {
            case .safe: return .green
            case .missing: return .red
            case .total: return .gray
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconName(for: status))
                        .foregroundColor(color)
                    Spacer()
                }
                
                Text("\(count)")
                    .font(.largeTitle.bold())
                    .foregroundColor(color)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        
        private func iconName(for status: SummaryStatus) -> String {
            switch status {
            case .safe: return "checkmark.circle.fill"
            case .missing: return "exclamationmark.triangle.fill"
            case .total: return "person.3.fill"
            }
        }
    }
}

// MARK: - Attendee Card
struct AttendeeCard: View {
    let attendee: Attendee
    var onManualCheckIn: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Placeholder/Image
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)

            VStack(alignment: .leading) {
                // FIX: Used attendee.name instead of hardcoded data
                Text(attendee.name).font(.headline).foregroundColor(.primary)
                Text(attendee.phone ?? "No phone number").font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()

            // --- Status/Action ---
            if attendee.status == .safe {
                // Status Tag: Safe
                Text("Safe")
                    .font(.caption2.bold())
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(6)
            } else if let checkIn = onManualCheckIn {
                // Button: Mark Safe (Only for Missing/InProgress)
                Button("Mark Safe", action: checkIn)
                    .font(.caption.bold())
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                
                // Status Tag: Missing/InProgress
                Text("Missing")
                    .font(.caption2.bold())
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
//    AttendanceView()
}
