import SwiftUI
import CoreLocation
import Combine
import PassKit

@MainActor
final class AppState: ObservableObject {
    // Current nearest place & its recommendations
    @Published var currentPlace: NearbyPlace?
    @Published var recommendations: [CardRecommendation] = []
    @Published var isSearching = false
    @Published var searchError: String?

    // Nearby pins for the map
    @Published var nearbyPlaces: [NearbyPlace] = []

    // All cards (wallet state persisted in UserDefaults)
    @Published var cards: [CreditCard] = [] {
        didSet { persistWallet() }
    }

    // Tab selection — tapping a notification deep-links to .recommendations
    @Published var selectedTab: Tab = .home
    @Published var showRecommendationSheet = false

    // Network detection
    @Published var detectedNetworks: Set<PKPaymentNetwork> = []
    @Published var suggestedCards: [CreditCard] = []

    enum Tab: Hashable { case home, wallet, settings }

    private let placesService = PlacesService()
    private var searchTask: Task<Void, Never>?
    private var lastSearchedCoord: CLLocationCoordinate2D?

    init() {
        cards = loadWallet()
        runWalletDetection()
    }

    func runWalletDetection() {
        let result = WalletDetectionService.detect(cards: cards)
        detectedNetworks = result.detectedNetworks
        suggestedCards = result.suggestedCards
    }

    // MARK: - Location-triggered search

    func onLocationUpdate(_ coord: CLLocationCoordinate2D,
                          notificationManager: NotificationManager) {
        // Debounce: only re-search if we've moved > 30 m
        if let last = lastSearchedCoord,
           distanceMeters(last, coord) < 30 { return }
        lastSearchedCoord = coord

        searchTask?.cancel()
        searchTask = Task {
            await searchPlaces(at: coord,
                               notificationManager: notificationManager)
        }
    }

    private func searchPlaces(at coord: CLLocationCoordinate2D,
                               notificationManager: NotificationManager) async {
        isSearching = true
        searchError = nil
        do {
            async let nearest = placesService.nearestPlace(at: coord)
            async let nearby  = placesService.nearbyPlaces(at: coord)

            let (place, pins) = try await (nearest, nearby)

            // Build recommendations
            let recs = CardRecommender.recommend(for: place, cards: cards)
            currentPlace   = place
            recommendations = recs
            nearbyPlaces   = pins

            // Fire notification for best wallet card
            if let best = recs.first(where: { $0.card.isInWallet }) ?? recs.first {
                notificationManager.notify(recommendation: best)
            }
        } catch PlacesError.noResults {
            searchError = nil   // silently ignore; user might be outdoors
        } catch {
            searchError = error.localizedDescription
        }
        isSearching = false
    }

    // MARK: - Manual refresh

    func refresh(coord: CLLocationCoordinate2D?,
                 notificationManager: NotificationManager) {
        guard let coord else { return }
        lastSearchedCoord = nil
        onLocationUpdate(coord, notificationManager: notificationManager)
    }

    // MARK: - Wallet persistence

    func toggleWallet(card: CreditCard) {
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[idx].isInWallet.toggle()
        if let place = currentPlace {
            recommendations = CardRecommender.recommend(for: place, cards: cards)
        }
        runWalletDetection()
    }

    private func persistWallet() {
        let walletIDs = cards.filter(\.isInWallet).map(\.id.uuidString)
        UserDefaults.standard.set(walletIDs, forKey: "fleeceWallet")
    }

    private func loadWallet() -> [CreditCard] {
        let walletIDs = Set(
            UserDefaults.standard.stringArray(forKey: "fleeceWallet") ?? []
        )
        return CardDatabase.all.map { card in
            var c = card
            c.isInWallet = walletIDs.contains(card.id.uuidString)
            return c
        }
    }

    // MARK: - Util

    private func distanceMeters(_ a: CLLocationCoordinate2D,
                                 _ b: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let loc2 = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return loc1.distance(from: loc2)
    }
}

