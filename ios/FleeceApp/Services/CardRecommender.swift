import Foundation

struct CardRecommender {
    /// Returns all cards ranked by effective reward rate for the given place,
    /// wallet-owned cards surfaced first within the same tier.
    static func recommend(for place: NearbyPlace, cards: [CreditCard]) -> [CardRecommendation] {
        let category = place.category

        let sorted = cards
            .map { card in
                CardRecommendation(
                    card: card,
                    multiplier: card.multiplier(for: category),
                    category: category,
                    place: place,
                    rank: 0
                )
            }
            .sorted {
                // Primary: effective rate descending
                if $0.effectiveRate != $1.effectiveRate {
                    return $0.effectiveRate > $1.effectiveRate
                }
                // Secondary: wallet cards first
                if $0.card.isInWallet != $1.card.isInWallet {
                    return $0.card.isInWallet
                }
                // Tertiary: lower annual fee
                return $0.card.annualFee < $1.card.annualFee
            }

        return sorted.enumerated().map { idx, rec in
            CardRecommendation(
                card: rec.card,
                multiplier: rec.multiplier,
                category: rec.category,
                place: rec.place,
                rank: idx + 1
            )
        }
    }

    /// Returns the single best wallet card (for notifications).
    /// Falls back to the globally best card if the wallet is empty.
    static func bestCard(for place: NearbyPlace, cards: [CreditCard]) -> CardRecommendation? {
        let all = recommend(for: place, cards: cards)
        return all.first(where: { $0.card.isInWallet }) ?? all.first
    }
}
