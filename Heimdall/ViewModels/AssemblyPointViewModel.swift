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
                guard self?.newName.isEmpty == false else { return }
                self?.newLatString = String(coordinate.latitude)
                self?.newLonString = String(coordinate.longitude)
                self?.locationManager.stopTracking()
            }
    }
    
    func useCurrentLocation() {
        if newName.isEmpty { newName = "Current Location" }
        
        let status = locationManager.permissionStatus
        if status == .denied || status == .restricted {
            showError(message: "Location access is denied. Please enable 'When In Use' in Settings.")
            return
        }
        
        // --- THE FIX ---
        // 1. Request temporary high accuracy using the public manager property
        locationManager.manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "EmergencyLocation")
        
        // 2. Start general tracking (which now correctly sets background flags)
        locationManager.startTracking()
        
        showError(message: "Fetching GPS location...")
        
        // If location is immediately available, use it
        if let location = locationManager.userLocation?.coordinate {
            newLatString = String(location.latitude)
            newLonString = String(location.longitude)
            self.errorMessage = nil
            self.showError = false
            locationManager.stopTracking()
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
