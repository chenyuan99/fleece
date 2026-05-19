import CoreLocation
import MapKit

enum PlacesError: LocalizedError {
    case noResults
    case searchFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noResults:            return "No places found at your location."
        case .searchFailed(let e):  return e.localizedDescription
        }
    }
}

actor PlacesService {
    /// Returns the nearest point-of-interest within `radius` meters using MapKit (free, no API key).
    func nearestPlace(at coord: CLLocationCoordinate2D,
                      radius: Int = Config.detectionRadius) async throws -> NearbyPlace {
        let items = try await searchItems(at: coord, radius: radius, limit: 1)
        guard let first = items.first else { throw PlacesError.noResults }
        return first
    }

    /// Returns up to `limit` nearby places for map pins.
    func nearbyPlaces(at coord: CLLocationCoordinate2D,
                      radius: Int = 200,
                      limit: Int = 10) async throws -> [NearbyPlace] {
        try await searchItems(at: coord, radius: radius, limit: limit)
    }

    // MARK: - Private

    private func searchItems(at coord: CLLocationCoordinate2D,
                              radius: Int,
                              limit: Int) async throws -> [NearbyPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "point of interest"
        request.region = MKCoordinateRegion(
            center: coord,
            latitudinalMeters: Double(radius),
            longitudinalMeters: Double(radius)
        )
        request.pointOfInterestFilter = .includingAll
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            return Array(response.mapItems.prefix(limit).map { $0.toNearbyPlace() })
        } catch {
            // MKError.placemarkNotFound == no results, not a hard failure
            let mkErr = error as? MKError
            if mkErr?.code == .placemarkNotFound { throw PlacesError.noResults }
            throw PlacesError.searchFailed(error)
        }
    }
}
