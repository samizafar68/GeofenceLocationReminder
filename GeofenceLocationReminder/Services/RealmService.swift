import Foundation
import RealmSwift

class RealmService {
    // MARK: - Properties
    static let shared = RealmService()
    private let realm: Realm

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm initialization failed: \(error)")
        }
    }

    // MARK: - Realm Function For Reminders
    func saveReminder(_ reminder: Reminder) {
        do {
            try realm.write {
                realm.add(reminder, update: .modified)
            }
        } catch {
            print("Realm write error: \(error.localizedDescription)")
        }
    }

    func deleteReminder(_ reminder: Reminder) {
        do {
            try realm.write {
                realm.delete(reminder)
            }
        } catch {
            print("Realm delete error: \(error.localizedDescription)")
        }
    }

    func getAllReminders() -> [Reminder] {
        Array(realm.objects(Reminder.self).sorted(byKeyPath: "createdAt", ascending: false))
    }
}

