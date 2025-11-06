import RealmSwift
import CoreLocation

// MARK: - Realm Reminder model
class Reminder: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lon: Double = 0.0
    @objc dynamic var radius: Double = 200.0
    @objc dynamic var note: String = ""
    @objc dynamic var createdAt: Date = Date()

    nonisolated override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String, coordinate: CLLocationCoordinate2D, radius: Double, note: String) {
        self.init()
        self.name = name
        self.lat = coordinate.latitude
        self.lon = coordinate.longitude
        self.radius = radius
        self.note = note
        self.createdAt = Date()
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

