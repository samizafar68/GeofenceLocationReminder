import SwiftUI
import CoreLocation

struct ContentView: View {
    // MARK: - Properties
    @EnvironmentObject var locationsVM: LocationsViewModel
    @EnvironmentObject var remindersVM: RemindersViewModel
    @EnvironmentObject var mapVM: MapViewModel
    @StateObject var locationService = LocationService.shared
    @State var showSettingsAlert = false
    @State var shouldAutoFetch = false
    @State var locationChangeToken: Int = 0

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    MapSection()
                    ActionButtons(fetchAction: fetchNearbyPOIs,
                                  shareAction: handleLocationPermission)
                    if locationsVM.isLoading {
                        ProgressView("Fetching nearby places...")
                            .padding()
                    }
                    RemindersList()
                }
                
                CenterToLocationButton {
                    mapVM.centerToUserLocation = true
                }
            }
            .navigationTitle("Geofence Reminders")
            .sheet(isPresented: $mapVM.showingCreateSheet) {
                CreateReminderSheet()
                    .environmentObject(mapVM)
                    .environmentObject(remindersVM)
            }
            .alert("Location Access Denied", isPresented: $showSettingsAlert) {
                Button("Open Settings") {
                    locationService.openAppSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location in Settings to fetch nearby places.")
            }
            .onChange(of: locationService.authorizationStatus) { status in
                handleAuthorizationChange(status)
            }
            .onChange(of: locationChangeToken) { _ in
                handleLocationChange()
            }
            .onChange(of: locationService.lastKnownLocation?.latitude) { _ in
                bumpLocationTokenIfNeeded()
            }
            .onChange(of: locationService.lastKnownLocation?.longitude) { _ in
                bumpLocationTokenIfNeeded()
            }
            .onAppear {
                NotificationService.shared.requestAuthorization { granted in
                    print("Notifications granted: \(granted)")
                }
                if (locationService.authorizationStatus == .authorizedAlways ||
                    locationService.authorizationStatus == .authorizedWhenInUse),
                   let _ = locationService.lastKnownLocation {
                    fetchNearbyPOIs()
                }
            }
        }
    }
}
