//
//  ActiveEmergencyViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import CoreLocation
internal import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ActiveEmergencyViewModel: ObservableObject {
    
    // --- Event State ---
    @Published var emergencyType: EmergencyType = .placeholder()
    @Published var instructions: [InstructionStep] = []
    @Published var eventStatus: Event.Status = .active
    @Published var userStatus: AttendeeStatus = .inProgress
    
    // --- UI State ---
    @Published var showSafeCheckInPrompt = false
    
    // --- Private Properties ---
    private let buildingID: String
    private let eventID: String
    private let emergencyTypeID: String
    private let userID: String
    private var db = Firestore.firestore()
    private var geofenceCancellable: AnyCancellable?
    private var eventListener: ListenerRegistration?
    private var attendanceListener: ListenerRegistration?
    
    // Models for data
    struct AssemblyPoint: Codable {
        var name: String
        var latitude: Double
        var longitude: Double
    }

    init(buildingID: String, eventID: String, emergencyTypeID: String,
         geofencePublisher: AnyPublisher<CLRegion, Never>) {
        
        self.buildingID = buildingID
        self.eventID = eventID
        self.emergencyTypeID = emergencyTypeID
        self.userID = Auth.auth().currentUser?.uid ?? "unknown"
        
        // Listen to the geofence "ding" from the LocationManager
        self.geofenceCancellable = geofencePublisher
            .sink { [weak self] region in
                // When we enter any region, show the prompt
                print("ViewModel: Received geofence event!")
                self?.showSafeCheckInPrompt = true
            }
    }
    
    /// Called from the View's .onAppear
    func start(locationManager: LocationManager) {
        Task {
            await fetchEmergencyData(locationManager: locationManager)
        }
        listenForEventChanges()
        listenForAttendanceChanges()
    }
    
    /// 1. Fetches assembly points and instructions, then tells LocationManager to start
    private func fetchEmergencyData(locationManager: LocationManager) async {
        do {
            // This is complex: the data is nested.
            // A better way: The push notification should include the emergencyType doc path.
            // For now, let's assume we can fetch it.
            
            // This is a placeholder for your actual data fetching
            // You need to fetch the 'emergencyType' doc from Firestore
            
            // MOCK DATA:
            let points = [
                AssemblyPoint(name: "Main Lobby", latitude: 37.332331, longitude: -122.031219),
                AssemblyPoint(name: "Parking Lot", latitude: 37.3321, longitude: -122.031)
            ]
            
            // Tell the location manager to monitor these points
            for (index, point) in points.enumerated() {
                locationManager.startMonitoring(
                    assemblyPoint: .init(latitude: point.latitude, longitude: point.longitude),
                    radius: 100, // 100 meters
                    identifier: "assembly_point_\(index)"
                )
            }
            
        } catch {
            print("Error fetching emergency data: \(error.localizedDescription)")
        }
    }
    
    /// 2. Listens for the admin to end the event
    private func listenForEventChanges() {
        eventListener?.remove()
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("events").document(eventID)
        
        eventListener = docRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let event = try? snapshot?.data(as: Event.self) else { return }
            self?.eventStatus = event.status
            // TODO: If status becomes 'completed', stop tracking
        }
    }
    
    /// 3. Listens for our own safety status
    private func listenForAttendanceChanges() {
        attendanceListener?.remove()
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("events").document(eventID)
                       .collection("attendance").document(userID)
        
        attendanceListener = docRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let attendee = try? snapshot?.data(as: Attendee.self) else { return } 
            self?.userStatus = attendee.status
        }
    }
    
    /// 4. Marks the user as SAFE in Firestore
    func markUserAsSafe() {
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("events").document(eventID)
                       .collection("attendance").document(userID)
        
        // Using 'merge: true' creates the doc if it doesn't exist
        docRef.setData(["status": AttendeeStatus.safe.rawValue], merge: true)
    }
    
    /// 5. Marks the user as NOT SAFE in Firestore
    func markUserAsNotSafe() {
        let docRef = db.collection("buildings").document(buildingID)
                       .collection("events").document(eventID)
                       .collection("attendance").document(userID)
        
        docRef.setData(["status": AttendeeStatus.inProgress.rawValue], merge: true)
    }
    
    deinit {
        geofenceCancellable?.cancel()
        eventListener?.remove()
        attendanceListener?.remove()
    }
}
