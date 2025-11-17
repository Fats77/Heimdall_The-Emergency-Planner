//
//  DrillCardView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 12/11/25.
//

import SwiftUI

struct DrillCardView: View {
    let building: CreateBuildingViewModel.Building
    
    var body: some View {
        VStack {
            // TODO: Load building.buildingPhotoURL
            Color.gray.opacity(0.3)
                .frame(height: 80)
                .cornerRadius(12)
            
            Text(building.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(building.description ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
//    DrillCardView(name: "Building 1")
}
