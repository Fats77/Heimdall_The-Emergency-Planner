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
    
    // FIX 1: Store the LocationManager instance reference
    private var activeLocationManager: LocationManager?
    
    // Models for data (AssemblyPoint structure is globally available via Models.swift)
    
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
        // FIX 2: Store the instance here
        self.activeLocationManager = locationManager
        
        Task {
            await fetchEmergencyData(locationManager: locationManager)
        }
        listenForEventChanges()
        listenForAttendanceChanges()
    }
    
    /// 1. Fetches emergency data (including assembly points) and starts tracking
    private func fetchEmergencyData(locationManager: LocationManager) async {
        do {
            // FIX: Use a Collection Group Query to find the EmergencyType document
            // anywhere under this building, avoiding the hard-coded floorID path.
            let querySnapshot = try await db.collectionGroup("emergencyTypes")
                .whereField("emergencyTypeID", isEqualTo: emergencyTypeID)
                .getDocuments()

            // Find the specific document by its ID within the query results
            guard let doc = querySnapshot.documents.first(where: { $0.documentID == emergencyTypeID }),
                  let fetchedEmergency = try? doc.data(as: EmergencyType.self)
            else {
                print("Error: EmergencyType document not found in any floor subcollection.")
                return
            }

            self.emergencyType = fetchedEmergency

            // 2. Setup Geofences if points exist
            if let points = fetchedEmergency.assemblyPoints {
                for (index, point) in points.enumerated() {
                    locationManager.startMonitoring(
                        assemblyPoint: .init(latitude: point.latitude, longitude: point.longitude),
                        radius: 100, // 100 meters radius
                        identifier: "assembly_point_\(eventID)_\(index)"
                    )
                }
            }

            locationManager.startTracking() // Start continuous location updates (for real-time admin view)

        } catch {
            print("Error fetching emergency data for tracking: \(error.localizedDescription)")
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
            
            // FIX 3: Implement the stop tracking logic
            if event.status == .completed {
                self?.activeLocationManager?.stopTracking()
                self?.activeLocationManager?.stopMonitoringAllRegions()
            }
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
