import Foundation
import Combine
internal import _LocationEssentials

@MainActor
class LocationsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var pois: [POI] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Function
    func loadPOIsFromOverpass(lat: Double, lon: Double, amenities: [String] = ["restaurant","cafe","park","bar","bank","atm","pub","landmark"]) async {
        isLoading = true
        var allPOIs: [POI] = []
        for amenity in amenities {
            await withCheckedContinuation { continuation in
                APIService.shared.fetchOpenStreetPOIs(latitude: lat, longitude: lon, radius: 2000, amenity: amenity) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let list):
                            allPOIs.append(contentsOf: list)
                        case .failure(let err):
                            self?.errorMessage = "Failed to load \(amenity): \(err)"
                            print(" Failed to load \(amenity): \(err)")
                        }
                        continuation.resume()
                    }
                }
            }
        }
        self.pois = allPOIs.reduce(into: [POI]()) { result, poi in
            if !result.contains(where: { $0.coordinate.latitude == poi.coordinate.latitude &&
                                         $0.coordinate.longitude == poi.coordinate.longitude }) {
                result.append(poi)
            }
        }
        isLoading = false
        print(" Loaded \(pois.count) total POIs.")
    }
}

