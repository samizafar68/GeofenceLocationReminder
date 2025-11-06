import Foundation
import Combine
import RealmSwift
import CoreLocation

@MainActor
class LocationsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var pois: [POI] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Functions
    func loadPOIsFromOverpass(lat: Double, lon: Double,
                              amenities: [String] = ["restaurant","cafe","park","bar","bank","atm","pub","landmark"]) async {
        isLoading = true
        var allPOIs: [POI] = []
        var apiSuccess = false
        for amenity in amenities {
            await withCheckedContinuation { continuation in
                APIService.shared.fetchOpenStreetPOIs(latitude: lat,
                                                      longitude: lon,
                                                      radius: 2000,
                                                      amenity: amenity) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let list):
                            allPOIs.append(contentsOf: list)
                            apiSuccess = true
                        case .failure(let err):
                            self?.errorMessage = "Failed to load \(amenity): \(err)"
                        }
                        continuation.resume()
                    }
                }
            }
        }
        let uniquePOIs = allPOIs.reduce(into: [POI]()) { result, poi in
            if !result.contains(where: {
                $0.coordinate.latitude == poi.coordinate.latitude &&
                $0.coordinate.longitude == poi.coordinate.longitude
            }) {
                result.append(poi)
            }
        }
        if !apiSuccess || uniquePOIs.isEmpty {
            let realm = try! await Realm()
            let reminders = realm.objects(Reminder.self)
            let localPOIs = reminders.map {
                POI(id: $0.id,
                    name: $0.name,
                    lat: $0.lat,
                    lon: $0.lon,
                    category: "Reminder")
            }
            self.pois = Array(localPOIs)
        } else {
            let realm = try! await Realm()
            let reminders = realm.objects(Reminder.self)
            let localPOIs = reminders.map {
                POI(id: $0.id,
                    name: $0.name,
                    lat: $0.lat,
                    lon: $0.lon,
                    category: "Reminder")
            }
            self.pois = uniquePOIs + Array(localPOIs)
        }
        isLoading = false
    }
}

