import Foundation

// MARK: - Overpass response models
struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let id: Int
    let lat: Double
    let lon: Double
    let tags: [String: String]?
}
