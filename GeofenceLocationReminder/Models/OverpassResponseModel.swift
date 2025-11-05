import Foundation

// MARK: - Overpass response models
 nonisolated struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

nonisolated struct OverpassElement: Codable {
    let id: Int
    let lat: Double
    let lon: Double
    let tags: [String: String]?
}
