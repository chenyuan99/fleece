# Apple Foundation Models in Fleece

How Fleece uses Apple's on-device language model (`FoundationModels` framework, iOS 26+).

---

## Current Usage

### Card explanation (implemented)

When the user opens the recommendations sheet on iOS 26 with Apple Intelligence enabled, `CardExplanationService` generates a one-sentence explanation of why each card is the top pick at the current merchant.

```swift
// Services/CardExplanationService.swift
@available(iOS 26.0, *)
actor CardExplanationService {
    func explanation(for recommendation: CardRecommendation) async -> String? {
        guard SystemLanguageModel.default.isAvailable else { return nil }
        let session = LanguageModelSession()
        let response = try await session.respond(to: buildPrompt(recommendation))
        return response.content
    }
}
```

**Result shown in `RecommendationRowView`:**
> *"Earns 4x Amex MR on every dining dollar — worth 7.2¢ each."*

**Fallback:** if Apple Intelligence is unavailable, the row shows the static multiplier and rate with no explanation text — no empty space, no error.

---

## Tool Calling

Tool calling lets the language model invoke Swift functions during inference to fetch real, live data rather than relying on what was baked into its training. The model decides when to call a tool, calls it, reads the result, and incorporates it into its response.

### How it works in FoundationModels

```swift
// 1. Define a tool
@available(iOS 26.0, *)
struct GetCardMultiplierTool: Tool {
    static let name = "get_card_multiplier"
    static let description = "Returns the reward multiplier for a card in a merchant category"

    @Parameter(description: "Card name e.g. 'Amex Gold'")
    var cardName: String

    @Parameter(description: "MCC category e.g. 'Dining'")
    var category: String

    func call(context: ToolContext) async throws -> ToolOutput {
        let cards = CardDatabase.all
        guard let card = cards.first(where: {
            $0.name.localizedCaseInsensitiveContains(cardName)
        }), let mcc = MCCCategory(rawValue: category) else {
            return ToolOutput("Card or category not found.")
        }
        let mult = card.multiplier(for: mcc)
        let rate = mult * card.pointValueCents
        return ToolOutput("\(cardName) earns \(mult)x on \(category) = \(rate)¢ per dollar (\(card.pointsProgram)).")
    }
}

// 2. Pass tools into the session
@available(iOS 26.0, *)
let session = LanguageModelSession(tools: [GetCardMultiplierTool()])
let response = try await session.respond(
    to: "I'm at a grocery store — which of my wallet cards earns the most?"
)
// The model calls GetCardMultiplierTool for each wallet card automatically,
// then synthesises the results into a final answer.
```

---

## Planned Tools for Fleece

### `GetWalletCardsTool`
Returns the user's current wallet cards so the model knows what's available without hallucinating card names.

```swift
@available(iOS 26.0, *)
struct GetWalletCardsTool: Tool {
    static let name = "get_wallet_cards"
    static let description = "Returns all credit cards currently in the user's Fleece wallet"
    var cards: [CreditCard]   // injected at session creation

    func call(context: ToolContext) async throws -> ToolOutput {
        let summary = cards.filter(\.isInWallet).map { card in
            "\(card.name) (\(card.issuer)) — base \(card.baseMultiplier)x, " +
            card.categoryMultipliers.map { "\($0.value)x \($0.key)" }.joined(separator: ", ")
        }.joined(separator: "\n")
        return ToolOutput(summary.isEmpty ? "No cards in wallet." : summary)
    }
}
```

### `GetNearbyPlacesTool`
Fetches the current nearest merchant via `MKLocalSearch` so the model always has up-to-date location context.

```swift
@available(iOS 26.0, *)
struct GetNearbyPlacesTool: Tool {
    static let name = "get_nearby_place"
    static let description = "Returns the nearest merchant at the user's current location"
    var coordinate: CLLocationCoordinate2D

    func call(context: ToolContext) async throws -> ToolOutput {
        let place = try await PlacesService().nearestPlace(at: coordinate)
        return ToolOutput(
            "Nearest place: \(place.name), category: \(place.category.rawValue) " +
            "(MCC codes: \(place.category.mccCodes.joined(separator: ", ")))"
        )
    }
}
```

### `GetCardROITool`
Calculates first-year ROI for a card using the user's spending profile — enables the model to answer "Is the Amex Gold worth the $325 fee for me?"

```swift
@available(iOS 26.0, *)
struct GetCardROITool: Tool {
    static let name = "get_card_roi"
    static let description = "Estimates first-year net value for a card given monthly spend"

    @Parameter(description: "Card name")
    var cardName: String
    @Parameter(description: "Monthly dining spend in USD")
    var diningMonthly: Double
    @Parameter(description: "Monthly grocery spend in USD")
    var groceriesMonthly: Double

    func call(context: ToolContext) async throws -> ToolOutput {
        guard let card = CardDatabase.all.first(where: {
            $0.name.localizedCaseInsensitiveContains(cardName)
        }) else { return ToolOutput("Card not found.") }

        let diningRate  = card.multiplier(for: .dining)  * card.pointValueCents / 100
        let groceryRate = card.multiplier(for: .groceries) * card.pointValueCents / 100
        let annualValue = (diningMonthly * diningRate + groceriesMonthly * groceryRate) * 12
        let net         = annualValue - Double(card.annualFee)

        return ToolOutput(
            "\(card.name): annual rewards ≈ $\(String(format: "%.0f", annualValue)), " +
            "net after $\(card.annualFee) fee = $\(String(format: "%.0f", net))"
        )
    }
}
```

---

## Wiring It Together — Multi-tool Session

With all three tools the model can answer complex, personalised questions without hallucinating:

```swift
@available(iOS 26.0, *)
func askFleece(question: String, coord: CLLocationCoordinate2D, cards: [CreditCard]) async -> String? {
    guard SystemLanguageModel.default.isAvailable else { return nil }

    let session = LanguageModelSession(
        tools: [
            GetWalletCardsTool(cards: cards),
            GetNearbyPlacesTool(coordinate: coord),
            GetCardROITool()
        ],
        instructions: """
        You are a concise credit card expert for the Fleece app.
        Use the provided tools to get real data before answering.
        Keep answers under 40 words. Never invent card names or rates.
        """
    )

    let response = try? await session.respond(to: question)
    return response?.content
}
```

**Example interaction:**
```
User:  "Am I using the right card here?"
Model: [calls get_nearby_place] → "Ippudo Ramen, Dining"
       [calls get_wallet_cards]  → "Amex Gold (4x Dining), Chase CFU (3x Dining)"
       [synthesises]
       "Yes — Amex Gold earns 4x MR (7.2¢/dollar) at this restaurant.
        That's your best wallet card for Dining."
```

---

## Availability & Fallback

| iOS | Device | Apple Intelligence | Behaviour |
|---|---|---|---|
| iOS 26+ | iPhone 15 Pro / 16 series | On | Full AI explanations + tool calling |
| iOS 26+ | iPhone 15 Pro / 16 series | Off | Static display only |
| iOS 26+ | Older device | N/A | Static display only |
| iOS 17–25 | Any | N/A | Static display only |

All AI features are checked with `#available(iOS 26.0, *)` and `SystemLanguageModel.default.isAvailable`. The app is fully functional without them.

---

## References

- [FoundationModels framework — Apple Developer](https://developer.apple.com/documentation/foundationmodels)
- [Tool calling guide — Apple Developer](https://developer.apple.com/documentation/foundationmodels/tool)
- [`@Generable` structured output](https://developer.apple.com/documentation/foundationmodels/generable)
- [WWDC 2025 — Explore the Foundation Models framework](https://developer.apple.com/videos/wwdc2025)
