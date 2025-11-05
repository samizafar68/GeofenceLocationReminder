import Foundation
import MapKit
import Combine

@MainActor
class MapViewModel: ObservableObject {
    // MARK: - Properties
    @Published var selectedPOI: POI?
    @Published var showingCreateSheet: Bool = false

    func annotation(for poi: POI) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = poi.coordinate
        annotation.title = poi.name
        annotation.subtitle = poi.category ?? "Unknown"
        return annotation
    }
}

