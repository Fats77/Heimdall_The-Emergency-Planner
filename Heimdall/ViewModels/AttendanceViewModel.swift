//
//  AttendanceViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
internal import Combine

@MainActor
class AttendanceViewModel: ObservableObject {
    
    @Published var allAttendees: [Attendee] = []
    @Published var searchText: String = ""
    
    // --- 1. Summary Properties (for your top info box) ---
    var totalCount: Int { allAttendees.count }
    var safeCount: Int { allAttendees.filter { $0.status == .safe }.count }
    var inProgressCount: Int { allAttendees.filter { $0.status == .inProgress }.count }
    
    // --- 2. Filtered Lists (for your search bar) ---
    private var filteredAttendees: [Attendee] {
        if searchText.isEmpty {
            return allAttendees
        } else {
            return allAttendees.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // These two computed properties will power your two lists
    var inProgressAttendees: [Attendee] {
        filteredAttendees.filter { $0.status == .inProgress }.sorted { $0.name < $1.name }
    }
    var safeAttendees: [Attendee] {
        filteredAttendees.filter { $0.status == .safe }.sorted { $0.name < $1.name }
    }
    
    // --- 3. Firebase Properties ---
    private let buildingID: String
    private let eventID: String
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init(buildingID: String, eventID: String) {
        self.buildingID = buildingID
        self.eventID = eventID
        listenForAttendanceUpdates()
    }
    
    deinit {
        listener?.remove()
    }
    
    /// Listens for real-time updates on the attendance subcollection
    func listenForAttendanceUpdates() {
        listener?.remove()
        
        let query = db.collection("buildings").document(buildingID)
                      .collection("events").document(eventID)
                      .collection("attendance")
        
        listener = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error fetching attendance: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.allAttendees = documents.compactMap {
                try? $0.data(as: Attendee.self)
            }
        }
    }
    
    /// Feature 9: Manually check in a user
    func manualCheckIn(attendee: Attendee) {
        guard let attendeeID = attendee.id else { return }
        
        let docRef = db.collection("buildings").document(buildingID)
                      .collection("events").document(eventID)
                      .collection("attendance").document(attendeeID)
        
        docRef.updateData([
            "status": AttendeeStatus.safe.rawValue,
            "safeTimestamp": FieldValue.serverTimestamp(),
            "manuallyCheckedInBy": Auth.auth().currentUser?.uid ?? "unknown_coordinator"
        ])
    }
    
    /// Feature 4: Admin can stop the event
    func stopEvent() {
        let docRef = db.collection("buildings").document(buildingID)
                      .collection("events").document(eventID)
        
        docRef.updateData([
            "status": "completed",
            "endTime": FieldValue.serverTimestamp()
        ])
    }
    
    /// Role 5: Export to Excel (Cloud Function)
    func exportToExcel() {
        // This would call a Cloud Function
        print("Calling Cloud Function 'exportAttendance' for event \(eventID)")
        // e.g., EventService.shared.exportEvent(eventID: eventID)
    }
}
