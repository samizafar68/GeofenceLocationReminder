import SwiftUI
import CoreLocation

struct ContentView: View {
    // MARK: - Properties
    @EnvironmentObject var locationsVM: LocationsViewModel
    @EnvironmentObject var remindersVM: RemindersViewModel
    @EnvironmentObject var mapVM: MapViewModel
    @StateObject var locationService = LocationService.shared
    @State private var showSettingsAlert = false

    var body: some View {
        NavigationView {
            VStack {
                MapViewRepresentable()
                    .frame(height: 360)
                    .cornerRadius(10)
                    .padding(.horizontal)
                HStack(spacing: 20) {
                    Button {
                        fetchNearbyPOIs()
                    } label: {
                        Label("Fetch Nearby", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        handleLocationPermission()
                    } label: {
                        Label("Share Location", systemImage: "location.fill")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 10)
                if locationsVM.isLoading {
                    ProgressView("Fetching nearby places...")
                        .padding()
                }
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
            .navigationTitle("Geofence Reminders")
            .sheet(isPresented: $mapVM.showingCreateSheet) {
                CreateReminderSheet()
                    .environmentObject(mapVM)
                    .environmentObject(remindersVM)
            }
            .alert("Location Access Denied",
                   isPresented: $showSettingsAlert) {
                Button("Open Settings") {
                    locationService.openAppSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location in Settings to fetch nearby places.")
            }
            .onChange(of: locationService.authorizationStatus) { status in
                if status == .denied {
                    showSettingsAlert = true
                }
            }
            .onAppear {
                NotificationService.shared.requestAuthorization { granted in
                    print(" Notifications granted: \(granted)")
                }
            }
        }
    }

    private func handleLocationPermission() {
        switch locationService.authorizationStatus {
        case .notDetermined:
            locationService.requestPermissions()
        case .denied:
            showSettingsAlert = true
        default:
            print(" Location already allowed.")
        }
    }

    private func fetchNearbyPOIs() {
        if let coord = locationService.lastKnownLocation {
            Task {
                await locationsVM.loadPOIsFromOverpass(
                    lat: coord.latitude,
                    lon: coord.longitude,
                    amenities: ["restaurant","cafe","park","landmark","bank","atm"]
                )
            }
        } else {
            print("No location yet. Tap 'Share Location' first.")
        }
    }
}

