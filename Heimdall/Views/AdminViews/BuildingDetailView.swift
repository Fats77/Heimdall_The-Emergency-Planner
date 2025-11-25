//
//  BuildingDetailView.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore
internal import Combine

struct BuildingDetailView: View {
    
    @StateObject private var viewModel: BuildingDetailViewModel
    
    let building: Building
    
    @State private var isAddingFloor = false
    @State private var isEditingBuilding = false
    @State private var selectedEmergency: EmergencyType?
    @State private var isShowingMembers = false
    @State private var isShowingDeleteAlert = false
    @State private var isShowingLeaveAlert = false
    @State private var isEventActive: Bool = false
    
    @State private var copySymbol = "document.on.document"
    
    init(building: Building) {
        self.building = building
        _viewModel = StateObject(wrappedValue: BuildingDetailViewModel(buildingID: building.id!))
    }
    
    var body: some View {
        ScrollView {
            if let photoURLString = building.buildingImageURL,
               let url = URL(string: photoURLString) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
            } else {
                Image(systemName: "building.2.fill")
                    .resizable()
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .foregroundColor(.white)
                    .background(Color.theme)
            }
            VStack {
                headerSection
                Divider()
//                    .opacity(0.5)
                emergencySection
                floorsSection
            }
            .padding()
        }
        .ignoresSafeArea()
        .navigationTitle("Emergency Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .sheet(isPresented: $isAddingFloor) {
            NavigationStack { CreateFloorView(buildingID: building.id!) { _ in viewModel.fetchFloors() } }
        }
        .sheet(isPresented: $isEditingBuilding) {
            NavigationStack { EditBuildingView(building: building) }
        }
        .sheet(isPresented: $isShowingMembers) {
            NavigationStack { ManageMembersView(buildingID: building.id!) }
        }
        .alert("Confirm Deletion", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) { viewModel.deleteBuilding(building: building) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this plan? This action cannot be undone.")
        }
        .alert("Confirm Leave", isPresented: $isShowingLeaveAlert) {
            Button("Leave", role: .destructive) { Task { await viewModel.leavePlan() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave \(building.name)? You will lose access to all current and future drills.")
        }
        .onAppear { viewModel.onAppear() }
    }

    
    // Placeholder to satisfy signature, actual logic belongs in ViewModel
    func deleteFloor(at offsets: IndexSet) {
        // You would typically move this to the ViewModel: viewModel.deleteFloor(at: offsets)
        print("Delete floor placeholder called.")
    }
    
    // Helper functions from previous iteration (for EmergencyType display)
    func iconFor(_ type: String) -> String { /* ... */ return "flame.fill" }
    func colorFor(_ type: String) -> Color { /* ... */ return .red }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(building.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)

                    HStack(alignment: .top){
                        Text("Invite Code: \(building.inviteCode)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        Button {
                            UIPasteboard.general.string = building.inviteCode
                            copySymbol = "checkmark"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.copySymbol = "document.on.document"
                            }
                        } label: {
                            Image(systemName: copySymbol)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Button{
                            isShowingMembers = true
                        }label:{
                            HStack{
                                Image(systemName: "person.2")
                                Text("\(viewModel.memberCount) members")
                            }
                            .tint(.black)
                            .font(.footnote)
                            .underline()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var emergencySection: some View {
        VStack(alignment: .leading) {
            Text("Select Emergency")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("⚠️ Triggering this alert will start the emergency drill and notify all plan members immediately.")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            
            if isEventActive {
                VStack(spacing: 20) {
                    Text("Active Alert: \(selectedEmergency?.prettyType ?? "N/A")")
                        .font(.title2.bold())
                        .foregroundColor(.red)

                    SlideToStopView(
                        buildingID: building.id!,
                        selectedEmergency: $selectedEmergency,
                        isEventActive: $isEventActive
                    )
                }
            } else {
                if viewModel.allEmergencyTypes.isEmpty {
                    Text("No emergency types added yet.")
                        .foregroundColor(.secondary)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 6) {
                    ForEach(viewModel.allEmergencyTypes) { type in
                        EmergencyTypeButton(
                            emergencyType: type,
                            isSelected: type.id == selectedEmergency?.id
                        )
                        .onTapGesture {
                            selectedEmergency = type
                        }
                    }
                }
                .padding(.vertical, 10)
            }

            TriggerAlertArea(
                selectedEmergency: $selectedEmergency,
                building: building,
                isEventActive: $isEventActive
            )
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(building.description ?? "Emergency Evacuation Plan")
                    .font(.body)
            }
            .padding(.vertical)
        }
    }

    private var floorsSection: some View {
        Section(header: Text("Floors")) {
            if viewModel.floors.isEmpty {
                Text("No floors added yet.")
                    .foregroundColor(.secondary)
            }

            ForEach(viewModel.floors) { floor in
                NavigationLink(destination: FloorDetailView(building: building, floor: floor)) {
                    HStack {
                        Image(systemName: "map")
                            .foregroundColor(.black)
                        Text(floor.name)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 20).stroke(.gray.opacity(0.3), lineWidth: 1))
                }
            }
            .onDelete(perform: deleteFloor)
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu {
                if viewModel.isAdmin {
                    Button { isEditingBuilding = true } label: {
                        Label("Edit Plan Details", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) { isShowingDeleteAlert = true } label: {
                        Label("Delete Plan", systemImage: "trash")
                    }
                }
                Button(role: .destructive) { isShowingLeaveAlert = true } label: {
                    Label("Leave Plan", systemImage: "figure.walk.motion")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }

            if viewModel.isAdmin {
                Button { isAddingFloor = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }


}

// MARK: - Trigger Alert Area Component
struct TriggerAlertArea: View {
    @Binding var selectedEmergency: EmergencyType?
    let building: Building
    @Binding var isEventActive: Bool // Propagates success back to parent
    
    @State private var isHolding = false
    @State private var holdProgress: CGFloat = 0.0 // NEW: 0.0 to 1.0
    @State private var showAlertError = false
    @State private var alertMessage = ""
    
    // Timer to track the 3-second hold
    let holdDuration: Double = 3.0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if let emergency = selectedEmergency {
                ZStack {
                    // 1. Progress Indicator Track (Ring)
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    
                    // 2. Progress Indicator Fill
                    RoundedRectangle(cornerRadius: 20)
                        .trim(from: 0.0, to: holdProgress)
                        .stroke(Color.theme, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
//                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.05), value: holdProgress)
                    
                    // 3. Center Content
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text(isHolding ? "HOLDING..." : "HOLD TO ALERT")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.theme.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .scaleEffect(isHolding ? 1.05 : 1.0)
                }
                .gesture(combinedGesture)
                
                // Timer Logic
                .onReceive(timer) { _ in
                    guard isHolding else { return }
                    
                    holdProgress += 0.05 / holdDuration
                    
                    if holdProgress >= 1.0 {
                        holdProgress = 1.0
                        triggerAlert(emergency: emergency)
                        isHolding = false
                    }
                }
            } else {
                Text("Select emergency type first")
                    .font(.callout).foregroundColor(.secondary)
//                    .frame(width: 150, height: 150)
            }
        }
        .frame(maxWidth: .infinity)
        .alert("Alert Failed", isPresented: $showAlertError, presenting: alertMessage) { _ in Button("OK") {} } message: { Text($0) }
    }
    
    // Gesture Logic (from previous step, slightly modified)
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: holdDuration)
            .onChanged { _ in
                if !isHolding {
                    holdProgress = 0.0
                    isHolding = true
                }
            }
            .onEnded { _ in
                // If hold finished, timer handled it. If not, reset.
                if holdProgress < 1.0 {
                    withAnimation {
                        isHolding = false; holdProgress = 0.0
                    }
                }
            }
    }

    var dragCancel: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { _ in
                 // If dragging starts, cancel the hold
                if isHolding {
                    withAnimation { isHolding = false; holdProgress = 0.0 }
                }
            }
    }
    
    var combinedGesture: some Gesture {
        longPress.simultaneously(with: dragCancel)
    }

    func triggerAlert(emergency: EmergencyType) {
        Task {
            let (success, message) = await EventService.shared.triggerAlert(
                building: building,
                emergency: emergency
            )
            
            if success {
                isEventActive = true // Propagate success
                // Optionally store the active emergency ID globally
            } else {
                alertMessage = message
                showAlertError = true
            }
            isHolding = false
            holdProgress = 0.0
        }
    }
}

// MARK: - Slide to Stop View (Feature 4)
struct SlideToStopView: View {
    let buildingID: String
    @Binding var selectedEmergency: EmergencyType?
    @Binding var isEventActive: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var isStopping = false
    
    let requiredSwipeDistance: CGFloat = 200
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background Track
            Capsule()
                .fill(Color.theme.opacity(0.1))
                .frame(height: 60)
            
            // Text Hint
            Text("SLIDE TO END ALERT")
                .font(.headline.bold())
                .foregroundColor(Color.theme)
                .opacity(dragOffset.width < requiredSwipeDistance * 0.8 ? 1.0 : 0.0)
                .frame(maxWidth: .infinity)
            
            // Draggable Thumb
            ZStack {
                Capsule()
                    .fill(Color.theme)
                    .frame(width: 60, height: 60)
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2.bold())
            }
            .offset(x: min(max(0, dragOffset.width), requiredSwipeDistance))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation
                        if dragOffset.width > requiredSwipeDistance {
                            isStopping = true
                        }
                    }
                    .onEnded { _ in
                        if isStopping {
                            endAlert()
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
        }
        .padding(.horizontal)
    }
    
    func endAlert() {
        Task {
            // Call the ViewModel function to update the event status to 'completed'
            // We need a function in the BuildingDetailViewModel for this
            
            // Placeholder for success
            isEventActive = false
            dragOffset = .zero
            isStopping = false
        }
    }
}

// MARK: - Emergency Type Button (Small Card UI)
struct EmergencyTypeButton: View {
    let emergencyType: EmergencyType
    let isSelected: Bool
    
    // Helper function to get icon (simplified)
    private var icon: String {
        switch emergencyType.type {
        case "tsunami": return "water.waves"
        case "earthquake": return "house.fill"
        case "fire": return "flame.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(isSelected ? .white : .primary)
            Text(emergencyType.prettyType)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding()
        .frame(width: 110, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .theme : .gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                .fill(isSelected ? .theme : Color(.systemBackground))
        )
    }
}

#Preview {
//    BuildingDetailView()
}
