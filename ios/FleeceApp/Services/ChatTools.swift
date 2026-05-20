#if canImport(FoundationModels)
import FoundationModels

// MARK: - Argument types (@Generable structs the model populates)

@available(iOS 26.0, *)
@Generable
struct NoArguments {}

@available(iOS 26.0, *)
@Generable
struct MCCLookupArguments {
    @Guide(description: "4-digit MCC code e.g. '5812'")
    var code: String
}

@available(iOS 26.0, *)
@Generable
struct ROIArguments {
    @Guide(description: "Card name e.g. 'Amex Gold'")
    var cardName: String
    @Guide(description: "Monthly dining spend in USD, 0 if unknown")
    var diningMonthly: Double
    @Guide(description: "Monthly grocery spend in USD, 0 if unknown")
    var groceriesMonthly: Double
    @Guide(description: "Monthly travel spend in USD, 0 if unknown")
    var travelMonthly: Double
    @Guide(description: "Monthly gas spend in USD, 0 if unknown")
    var gasMonthly: Double
    @Guide(description: "Monthly other spend in USD, 0 if unknown")
    var otherMonthly: Double
}

// MARK: - Tools

@available(iOS 26.0, *)
struct GetWalletCardsTool: Tool {
    let name = "get_wallet_cards"
    let description = "Returns all credit cards in the user's Fleece wallet with reward multipliers per category. Always call before making recommendations."
    let cards: [CreditCard]

    func call(arguments: NoArguments) async throws -> String {
        let wallet = cards.filter(\.isInWallet)
        guard !wallet.isEmpty else {
            return "No cards in wallet. Ask the user to add cards in the Wallet tab."
        }
        return wallet.map { card in
            "\(card.name) (\(card.issuer), $\(card.annualFee)/yr, \(card.pointsProgram)): " +
            card.categoryMultipliers.sorted { $0.value > $1.value }
                .map { "\(Int($0.value))x \($0.key)" }.joined(separator: ", ") +
            ", \(card.baseMultiplier)x everything else"
        }.joined(separator: "\n")
    }
}

@available(iOS 26.0, *)
struct LookupMCCTool: Tool {
    let name = "lookup_mcc"
    let description = "Returns the merchant category name and emoji for a 4-digit MCC code from the bundled offline database of 981 codes."

    func call(arguments: MCCLookupArguments) async throws -> String {
        let code = arguments.code.trimmingCharacters(in: .whitespaces)
        for category in MCCCategory.allCases {
            if category.mccCodes.contains(code) {
                return "MCC \(code) → \(category.rawValue) \(category.emoji)"
            }
        }
        return "MCC \(code) not found in local database."
    }
}

@available(iOS 26.0, *)
struct GetCardROITool: Tool {
    let name = "get_card_roi"
    let description = "Calculates first-year net value for a card given monthly spend. Use when user asks if a card is worth it or wants to compare value."

    func call(arguments: ROIArguments) async throws -> String {
        guard let card = CardDatabase.all.first(where: {
            $0.name.localizedCaseInsensitiveContains(arguments.cardName)
        }) else {
            return "Card '\(arguments.cardName)' not found. Available: \(CardDatabase.all.map(\.name).joined(separator: ", "))"
        }
        let spend: [(MCCCategory, Double)] = [
            (.dining, arguments.diningMonthly),
            (.groceries, arguments.groceriesMonthly),
            (.hotels, arguments.travelMonthly),
            (.gas, arguments.gasMonthly),
            (.other, arguments.otherMonthly),
        ]
        let annualRewards = spend.reduce(0.0) { sum, pair in
            sum + pair.1 * card.multiplier(for: pair.0) * card.pointValueCents / 100 * 12
        }
        let net = annualRewards - Double(card.annualFee)
        return "\(card.name) ($\(card.annualFee)/yr, \(card.pointsProgram)): " +
               "annual rewards ≈ $\(String(format: "%.0f", annualRewards)), " +
               "net = \(net >= 0 ? "+" : "")$\(String(format: "%.0f", net))"
    }
}

// MARK: - Structured response

@available(iOS 26.0, *)
@Generable
struct FleeceResponse {
    @Guide(description: "Direct answer, max 40 words. Never mention internal tool calls.")
    var answer: String
    @Guide(description: "Recommended card name from wallet, nil if not applicable")
    var recommendedCard: String?
    @Guide(description: "Effective reward rate as a percentage e.g. 7.2, nil if not applicable")
    var effectiveRate: Double?
    @Guide(description: "One short follow-up question, nil if answer is complete")
    var followUp: String?
    @Guide(description: "Monthly dining spend in USD if user mentioned it this turn, else nil")
    var diningMonthly: Double?
    @Guide(description: "Monthly grocery spend in USD if user mentioned it this turn, else nil")
    var groceriesMonthly: Double?
    @Guide(description: "Monthly travel spend in USD if user mentioned it this turn, else nil")
    var travelMonthly: Double?
    @Guide(description: "Monthly gas spend in USD if user mentioned it this turn, else nil")
    var gasMonthly: Double?
}

#endif
