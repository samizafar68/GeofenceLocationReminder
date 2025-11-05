import Foundation
import CoreLocation

// MARK: - Point of Interest Model
struct POI: Identifiable, Codable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let category: String?
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    var displayCategory: String {
        if let c = category, !c.isEmpty {
            return c
        } else {
            return "Unknown"
        }
    }
}

