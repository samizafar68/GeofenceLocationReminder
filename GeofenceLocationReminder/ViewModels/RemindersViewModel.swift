import Foundation
import CoreLocation
import Combine

@MainActor
class RemindersViewModel: ObservableObject {
    // MARK: - Properties
    @Published var reminders: [Reminder] = []
    @Published var lastError: String?

    init() {
        load()
    }
    
    // MARK: - Reminder Functions
    func load() {
        reminders = RealmService.shared.getAllReminders()
    }

    func addReminder(name: String, coordinate: CLLocationCoordinate2D, radius: Double, note: String) {
        let reminder = Reminder(name: name, coordinate: coordinate, radius: radius, note: note)
        RealmService.shared.saveReminder(reminder)
        LocationService.shared.startMonitoring(reminder: reminder)
        load()
    }

    func delete(_ reminder: Reminder) {
        LocationService.shared.stopMonitoring(reminder: reminder)
        RealmService.shared.deleteReminder(reminder)
        load()
    }
}

