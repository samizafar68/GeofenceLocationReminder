import SwiftUI
import CoreLocation

// MARK: - Subviews
extension ContentView {
    @ViewBuilder
    func MapSection() -> some View {
        MapViewRepresentable()
            .frame(height: 360)
            .cornerRadius(10)
            .padding(.horizontal)
    }
    
    struct ActionButtons: View {
        let fetchAction: () -> Void
        let shareAction: () -> Void
        
        var body: some View {
            HStack(spacing: 20) {
                Button(action: fetchAction) {
                    Label("Fetch Nearby", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: shareAction) {
                    Label("Share Location", systemImage: "location.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 10)
        }
    }
    
    @ViewBuilder
    func RemindersList() -> some View {
        List {
            Section(header: Text("Saved Reminders")) {
                if remindersVM.reminders.isEmpty {
                    Text("No reminders yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(remindersVM.reminders) { reminder in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reminder.name)
                                .font(.headline)
                            Text("\(Int(reminder.radius)) m • \(reminder.note)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let rem = remindersVM.reminders[index]
                            remindersVM.delete(rem)
                        }
                    }
                }
            }
        }
    }
    
    struct CenterToLocationButton: View {
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 26))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 25)
            .padding(.bottom, 90)
        }
    }
}

// MARK: - Handlers
extension ContentView {
    func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            shouldAutoFetch = true
        case .denied:
            showSettingsAlert = true
        default:
            break
        }
    }
    
    func handleLocationChange() {
        if shouldAutoFetch, let _ = locationService.lastKnownLocation {
            shouldAutoFetch = false
            fetchNearbyPOIs()
        }
    }
    
    func bumpLocationTokenIfNeeded() {
        if locationService.lastKnownLocation != nil {
            locationChangeToken &+= 1
        }
    }
}

// MARK: - Actions
extension ContentView {
    func handleLocationPermission() {
        switch locationService.authorizationStatus {
        case .notDetermined:
            locationService.requestPermissions()
        case .denied:
            showSettingsAlert = true
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location already allowed — fetching nearby...")
            fetchNearbyPOIs()
        @unknown default:
            break
        }
    }

    func fetchNearbyPOIs() {
        if let coord = locationService.lastKnownLocation {
            Task {
                await locationsVM.loadPOIsFromOverpass(
                    lat: coord.latitude,
                    lon: coord.longitude,
                    amenities: ["restaurant", "cafe", "park", "landmark", "bank", "atm"]
                )
            }
        } else {
            print("No location yet. Tap 'Share Location' first.")
        }
    }
}
