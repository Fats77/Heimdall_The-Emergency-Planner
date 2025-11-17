//
//  LocationManager.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import Foundation
import CoreLocation
internal import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    // Published properties to update the UI
    @Published var userLocation: CLLocation?
    @Published var permissionStatus: CLAuthorizationStatus
    
    // A PassthroughSubject to send events to our ViewModel
    // We'll use this to send "didEnterRegion" events
    let geofenceEventSubject = PassthroughSubject<CLRegion, Never>()

    override init() {
        self.permissionStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true // Required for tracking
        manager.showsBackgroundLocationIndicator = true // Required by Apple
    }
    
    /// 1. Request Location Permission
    func requestLocationPermission() {
        if permissionStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        // You also need "Always" permission for geofencing to work in the background.
        // You should ask for this later, with good justification.
        // For now, "When in Use" is a good start.
        
        // You must also request "Full Accuracy"
        manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "EmergencyLocation")
    }
    
    /// 2. Start Tracking
    func startTracking() {
        print("Location Manager: Starting location updates.")
        manager.startUpdatingLocation()
    }
    
    /// 3. Stop Tracking
    func stopTracking() {
        print("Location Manager: Stopping location updates.")
        manager.stopUpdatingLocation()
    }
    
    /// 4. Start Monitoring a Geofence
    func startMonitoring(assemblyPoint: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        // Make sure the device can do this
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            let region = CLCircularRegion(center: assemblyPoint, radius: radius, identifier: identifier)
            region.notifyOnEntry = true // We only care when they enter
            region.notifyOnExit = false
            
            print("Location Manager: Starting to monitor region \(identifier)")
            manager.startMonitoring(for: region)
        }
    }
    
    /// 5. Stop Monitoring All Geofences
    func stopMonitoringAllRegions() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    /// This is called when permission status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.permissionStatus = manager.authorizationStatus
        
        if permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways {
            startTracking()
        }
    }
    
    /// This is called with new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations.last
        // Here you would continuously update the user's location in Firestore
        // e.g., EventService.shared.updateUserLocation(locations.last)
    }
    
    /// This is called when the user ENTERS a geofence
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Location Manager: Did enter region \(region.identifier)")
        // Send this event to our ViewModel
        geofenceEventSubject.send(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed: \(error.localizedDescription)")
    }
}
