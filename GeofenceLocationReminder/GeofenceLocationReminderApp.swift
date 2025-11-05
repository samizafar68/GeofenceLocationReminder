import SwiftUI

@main
struct GeofenceLocationReminderApp: App {
    // MARK: - Properties
    @StateObject var locationsVM = LocationsViewModel()
    @StateObject var remindersVM = RemindersViewModel()
    @StateObject var mapVM = MapViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationsVM)
                .environmentObject(remindersVM)
                .environmentObject(mapVM)
        }
    }
}

