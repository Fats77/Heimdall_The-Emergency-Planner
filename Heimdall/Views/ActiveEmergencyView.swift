//
//  ActiveEmergencyView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
internal import Combine
import CoreLocation
import FirebaseFirestore

struct ActiveEmergencyView: View {
    
    // We pass these in when the view is created
    let buildingID: String
    let eventID: String
    let emergencyTypeID: String
    
    // The ViewModel to handle all logic
    @StateObject private var viewModel: ActiveEmergencyViewModel
    
    // The single instance of our location manager
    // Note: Must be StateObject for persistence, used directly for permission/tracking calls
    @StateObject private var locationManager = LocationManager()
    
    // We create the ViewModel and pass it the location manager's event publisher
    init(buildingID: String, eventID: String, emergencyTypeID: String) {
        self.buildingID = buildingID
        self.eventID = eventID
        self.emergencyTypeID = emergencyTypeID
        
        let manager = LocationManager()
        _locationManager = StateObject(wrappedValue: manager)
        _viewModel = StateObject(wrappedValue: ActiveEmergencyViewModel(
            buildingID: buildingID,
            eventID: eventID,
            emergencyTypeID: emergencyTypeID,
            geofencePublisher: manager.geofenceEventSubject.eraseToAnyPublisher()
        ))
    }
    
    var body: some View {
        VStack {
            if viewModel.userStatus == .safe {
                // Show a "You are safe" view
                YouAreSafeView(viewModel: viewModel)
            } else {
                // Show the active emergency details
                EmergencyInProgressView(viewModel: viewModel, locationManager: locationManager)
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
            viewModel.start(locationManager: locationManager)
        }
        .onDisappear {
            // Only stop tracking if the event is over or they are safe
            if viewModel.userStatus == .safe || viewModel.eventStatus == .completed {
                locationManager.stopTracking()
                locationManager.stopMonitoringAllRegions()
            }
        }
        // This is your feature: "we detected you near assembly point"
        .alert("Near Assembly Point", isPresented: $viewModel.showSafeCheckInPrompt, actions: {
            Button("Yes, Mark Me Safe") {
                viewModel.markUserAsSafe()
            }
            Button("Not Yet", role: .cancel) {}
        }, message: {
            Text("We've detected you are near an assembly point. Do you want to mark yourself as 'Safe'?")
        })
    }
}

