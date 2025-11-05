import Foundation
import Alamofire
import CoreLocation

enum APIError: Error {
    case badURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

// MARK: - Overpass API service for OpenStreetMap POIs
final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchOpenStreetPOIs(
        latitude: Double,
        longitude: Double,
        radius: Int = 2000,
        amenity: String = "resturaunt",
        completion: @escaping (Result<[POI], APIError>) -> Void
    ) {
        let query = """
        [out:json];
        node["amenity"="\(amenity)"](around:\(radius),\(latitude),\(longitude));
        out;
        """
        let url = "https://overpass-api.de/api/interpreter"
        let parameters: [String: String] = ["data": query]
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: OverpassResponse.self, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let overpass):
                    let pois = overpass.elements.map { element in
                        POI(
                            id: String(element.id),
                            name: element.tags?["name"] ?? "Unnamed",
                            lat: element.lat,
                            lon: element.lon,
                            category: element.tags?["amenity"]
                        )
                    }
                    completion(.success(pois))
                case .failure(let error):
                    completion(.failure(.requestFailed(error)))
                }
            }
    }
}


