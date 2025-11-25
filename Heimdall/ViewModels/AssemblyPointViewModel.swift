//
//  AssemblyPointViewModel.swift
//  Heimdall
//
//  Created by Kemas Deanova on 23/11/25.
//

import Foundation
import CoreLocation
internal import Combine
import FirebaseFirestore

// We assume AssemblyPoint, LocationManager are globally available

@MainActor
class AssemblyPointViewModel: ObservableObject {
    
    @Published var newName: String = ""
    @Published var newLatString: String = ""
    @Published var newLonString: String = ""
    
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isLoading = false // FIX: Added isLoading status
    
    private var locationManager = LocationManager()
    private var locationCancellable: AnyCancellable?
    
    var canAddPoint: Bool {
        !newName.isEmpty &&
        (Double(newLatString) != nil) &&
        (Double(newLonString) != nil)
    }
    
    init() {
        locationCancellable = locationManager.$userLocation
            .compactMap { $0?.coordinate }
            .sink { [weak self] coordinate in
                // Only update fields if we were actively requesting location (i.e., isLoading is true)
                guard self?.isLoading == true else { return }
                self?.newLatString = String(coordinate.latitude)
                self?.newLonString = String(coordinate.longitude)
                
                // Stop tracking once we have a valid location
                self?.locationManager.stopTracking()
                self?.isLoading = false
            }
    }
    
    func useCurrentLocation() {
        isLoading = true
        if newName.isEmpty { newName = "Current Location" }
        
        let status = locationManager.permissionStatus
        if status == .denied || status == .restricted {
            showError(message: "Location access is denied. Please enable 'When In Use' in Settings.")
            isLoading = false
            return
        }
        
        Task {
            locationManager.requestLocationPermission()
            // We expose the manager property via a specific public function in the LocationManager
            // to avoid the original error, so we must access it through that exposed layer:
            locationManager.manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "EmergencyLocation")
            locationManager.startTracking()
            
//            showError(message: "Fetching GPS location...")
            
            // Check for immediate location (simulators often return instantly)
            if let location = locationManager.userLocation?.coordinate {
                newLatString = String(location.latitude)
                newLonString = String(location.longitude)
                self.errorMessage = nil
                self.showError = false
                locationManager.stopTracking()
                isLoading = false
            }
            // If not immediate, the onReceive closure handles the update.
        }
    }
    
    func addPoint() -> AssemblyPoint? {
        guard let lat = Double(newLatString),
              let lon = Double(newLonString) else {
            showError(message: "Invalid latitude or longitude entered.")
            return nil
        }
        
        let newPoint = AssemblyPoint(name: newName, latitude: lat, longitude: lon)
        return newPoint
    }
    
    func resetFields() {
        newName = ""
        newLatString = ""
        newLonString = ""
    }
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
