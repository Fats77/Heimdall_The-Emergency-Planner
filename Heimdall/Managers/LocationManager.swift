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
    
    // FIX 1: Make the manager public but private(set)
    public private(set) var manager = CLLocationManager()
    
    // Published properties to update the UI
    @Published var userLocation: CLLocation?
    @Published var permissionStatus: CLAuthorizationStatus
    
    let geofenceEventSubject = PassthroughSubject<CLRegion, Never>()

    override init() {
        self.permissionStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        // FIX 2: Removed background updates here, only set on startTracking
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    // FIX 3: Simple request
    func requestLocationPermission() {
        if permissionStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // FIX 4: Set background properties *before* starting updates
    func startTracking() {
        print("Location Manager: Starting location updates.")
        manager.allowsBackgroundLocationUpdates = true // Set capability here
        manager.showsBackgroundLocationIndicator = true
        manager.startUpdatingLocation()
    }
    
    func stopTracking() {
        print("Location Manager: Stopping location updates.")
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
    }
    
    // MARK: - NEW: Public Geofencing Methods
    
    /// Public wrapper to start monitoring a geofence region.
    func startMonitoring(assemblyPoint: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(center: assemblyPoint, radius: radius, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            print("Location Manager: Starting to monitor region \(identifier)")
            manager.startMonitoring(for: region) // Call on the internal manager
        }
    }
    
    /// Public wrapper to stop monitoring all active geofences.
    func stopMonitoringAllRegions() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region) // Call on the internal manager
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    /// This is called when permission status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.permissionStatus = manager.authorizationStatus
        
        if permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways {
            // Note: startTracking() is called by the ViewModel when the user explicitly taps "Use My Current Location"
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
