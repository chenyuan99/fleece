import Foundation

// Hard-coded card data for 9 major US cards.
// Multipliers reflect published category bonuses as of mid-2025.
// Point values are conservative mid-market estimates (TPG/NerdWallet baseline).
enum CardDatabase {
    static let all: [CreditCard] = [
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000001")!,
            name: "Sapphire Reserve",
            issuer: "Chase",
            annualFee: 550,
            pointsProgram: "Chase UR",
            pointValueCents: 1.5,
            categoryMultipliers: [
                MCCCategory.dining.rawValue:        3,
                MCCCategory.hotels.rawValue:        3,
                MCCCategory.flights.rawValue:       3,
                MCCCategory.transit.rawValue:       3,
            ],
            baseMultiplier: 1,
            cardColor: "#1A1A2E",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000002")!,
            name: "Sapphire Preferred",
            issuer: "Chase",
            annualFee: 95,
            pointsProgram: "Chase UR",
            pointValueCents: 1.25,
            categoryMultipliers: [
                MCCCategory.dining.rawValue:        3,
                MCCCategory.groceries.rawValue:     3,
                MCCCategory.streaming.rawValue:     3,
                MCCCategory.hotels.rawValue:        2,
                MCCCategory.flights.rawValue:       2,
                MCCCategory.transit.rawValue:       2,
            ],
            baseMultiplier: 1,
            cardColor: "#1B4F72",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000003")!,
            name: "Freedom Unlimited",
            issuer: "Chase",
            annualFee: 0,
            pointsProgram: "Chase UR",
            pointValueCents: 1.0,
            categoryMultipliers: [
                MCCCategory.dining.rawValue:        3,
                MCCCategory.drugstore.rawValue:     3,
                MCCCategory.hotels.rawValue:        5,
                MCCCategory.flights.rawValue:       5,
                MCCCategory.transit.rawValue:       5,
            ],
            baseMultiplier: 1.5,
            cardColor: "#2C3E50",
            textColor: "#F39C12",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000004")!,
            name: "Gold Card",
            issuer: "American Express",
            annualFee: 325,
            pointsProgram: "Amex MR",
            pointValueCents: 1.8,
            categoryMultipliers: [
                MCCCategory.dining.rawValue:        4,
                MCCCategory.groceries.rawValue:     4,
                MCCCategory.flights.rawValue:       3,
            ],
            baseMultiplier: 1,
            cardColor: "#B8860B",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000005")!,
            name: "Platinum Card",
            issuer: "American Express",
            annualFee: 695,
            pointsProgram: "Amex MR",
            pointValueCents: 2.0,
            categoryMultipliers: [
                MCCCategory.flights.rawValue:       5,
                MCCCategory.hotels.rawValue:        5,
            ],
            baseMultiplier: 1,
            cardColor: "#A8A9AD",
            textColor: "#000000",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000006")!,
            name: "Blue Cash Preferred",
            issuer: "American Express",
            annualFee: 95,
            pointsProgram: "Cash Back",
            pointValueCents: 1.0,
            categoryMultipliers: [
                MCCCategory.groceries.rawValue:     6,
                MCCCategory.streaming.rawValue:     6,
                MCCCategory.gas.rawValue:           3,
                MCCCategory.transit.rawValue:       3,
            ],
            baseMultiplier: 1,
            cardColor: "#007DC3",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000007")!,
            name: "Bilt Mastercard",
            issuer: "Bilt / Wells Fargo",
            annualFee: 0,
            pointsProgram: "Bilt Points",
            pointValueCents: 1.5,
            categoryMultipliers: [
                MCCCategory.dining.rawValue:        3,
                MCCCategory.hotels.rawValue:        2,
                MCCCategory.flights.rawValue:       2,
                MCCCategory.transit.rawValue:       2,
            ],
            baseMultiplier: 1,
            cardColor: "#2D2D2D",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000008")!,
            name: "Venture X",
            issuer: "Capital One",
            annualFee: 395,
            pointsProgram: "Capital One Miles",
            pointValueCents: 1.7,
            categoryMultipliers: [
                MCCCategory.hotels.rawValue:        10,
                MCCCategory.flights.rawValue:       5,
            ],
            baseMultiplier: 2,
            cardColor: "#C0392B",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
        CreditCard(
            id: UUID(uuidString: "A0000001-0000-0000-0000-000000000009")!,
            name: "Double Cash",
            issuer: "Citi",
            annualFee: 0,
            pointsProgram: "Cash Back",
            pointValueCents: 1.0,
            categoryMultipliers: [:],
            baseMultiplier: 2,
            cardColor: "#212F3C",
            textColor: "#FFFFFF",
            isInWallet: false
        ),
    ]
}
