import Foundation
import CoreLocation
import Combine

@MainActor
class RemindersViewModel: ObservableObject {
    // MARK: - Properties
    @Published var reminders: [Reminder] = []
    @Published var lastError: String?
    @Published var showDuplicateAlert = false
    @Published var alertMessage = ""

    init() {
        load()
    }
    // MARK: - Function of Reminders
    func load() {
        reminders = RealmService.shared.getAllReminders()
    }
    
    func addReminder(name: String, coordinate: CLLocationCoordinate2D, radius: Double, note: String) -> Bool {
        if reminders.contains(where: { $0.lat == coordinate.latitude && $0.lon == coordinate.longitude }) {
            alertMessage = "A reminder for this location already exists."
            showDuplicateAlert = true
            return false
        }
        let reminder = Reminder(name: name, coordinate: coordinate, radius: radius, note: note)
        RealmService.shared.saveReminder(reminder)
        LocationService.shared.startMonitoring(reminder: reminder)
        load()
        return true
    }

    func delete(_ reminder: Reminder) {
        LocationService.shared.stopMonitoring(reminder: reminder)
        RealmService.shared.deleteReminder(reminder)
        load()
    }
}
