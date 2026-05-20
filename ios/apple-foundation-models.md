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

Three tools — all offline, all grounded in local data, zero hallucination risk on facts.

> **Why only three?**
> We deliberately excluded a `GetSpendingProfileTool`. iOS has no way to auto-detect
> spending from transactions without a backend + bank aggregation API (Plaid etc.),
> which kills our privacy-first, no-server stance. Manual entry in a settings screen
> would work technically, but users won't keep it updated.
>
> Better: let the model ask conversationally. The user says "I spend $600/month on dining"
> once and the model carries it in the context window for all subsequent calculations in
> that session. The context window *is* the spending profile.

---

### `GetWalletCardsTool`
Returns the user's current wallet cards so the model knows what's available without hallucinating card names or multipliers.

```swift
@available(iOS 26.0, *)
struct GetWalletCardsTool: Tool {
    static let name = "get_wallet_cards"
    static let description = "Returns all credit cards currently in the user's Fleece wallet with their reward multipliers per category"
    var cards: [CreditCard]   // injected at session creation

    func call(context: ToolContext) async throws -> ToolOutput {
        let wallet = cards.filter(\.isInWallet)
        guard !wallet.isEmpty else { return ToolOutput("No cards in wallet.") }
        let summary = wallet.map { card in
            "\(card.name) (\(card.issuer), $\(card.annualFee)/yr, \(card.pointsProgram)): " +
            card.categoryMultipliers.sorted { $0.value > $1.value }
                .map { "\(Int($0.value))x \($0.key)" }.joined(separator: ", ") +
            ", \(card.baseMultiplier)x everything else"
        }.joined(separator: "\n")
        return ToolOutput(summary)
    }
}
```

### `LookupMCCTool`
Looks up a merchant category code from the 981 bundled codes — fully offline. Lets the model answer "What category is MCC 5812?" without relying on training data.

```swift
@available(iOS 26.0, *)
struct LookupMCCTool: Tool {
    static let name = "lookup_mcc"
    static let description = "Returns the merchant category name for a 4-digit MCC code. Use when the user mentions a specific store type or merchant code."

    @Parameter(description: "4-digit MCC code e.g. '5812'")
    var code: String

    func call(context: ToolContext) async throws -> ToolOutput {
        // MCCCategory already has mccCodes arrays — reverse-lookup
        for category in MCCCategory.allCases {
            if category.mccCodes.contains(code) {
                return ToolOutput("MCC \(code) → \(category.rawValue) \(category.emoji)")
            }
        }
        return ToolOutput("MCC \(code) not found in local database.")
    }
}
```

### `GetCardROITool`
Calculates first-year net value for any card in `CardDatabase` given spend numbers the model has extracted from the conversation. Grounds ROI answers in local math — no Brave search needed for the 9 cards in the database.

```swift
@available(iOS 26.0, *)
struct GetCardROITool: Tool {
    static let name = "get_card_roi"
    static let description = "Calculates first-year net value for a card given monthly spend amounts. Use after the user mentions their spending habits."

    @Parameter(description: "Card name e.g. 'Amex Gold'")
    var cardName: String
    @Parameter(description: "Monthly dining spend in USD (0 if unknown)")
    var diningMonthly: Double
    @Parameter(description: "Monthly grocery spend in USD (0 if unknown)")
    var groceriesMonthly: Double
    @Parameter(description: "Monthly travel spend in USD (0 if unknown)")
    var travelMonthly: Double
    @Parameter(description: "Monthly gas spend in USD (0 if unknown)")
    var gasMonthly: Double
    @Parameter(description: "Monthly other spend in USD (0 if unknown)")
    var otherMonthly: Double

    func call(context: ToolContext) async throws -> ToolOutput {
        guard let card = CardDatabase.all.first(where: {
            $0.name.localizedCaseInsensitiveContains(cardName)
        }) else { return ToolOutput("Card '\(cardName)' not found in local database.") }

        let spend: [(MCCCategory, Double)] = [
            (.dining, diningMonthly),
            (.groceries, groceriesMonthly),
            (.hotels, travelMonthly),   // broad travel proxy
            (.gas, gasMonthly),
            (.other, otherMonthly),
        ]
        let annualRewards = spend.reduce(0.0) { sum, pair in
            let (category, monthly) = pair
            let rate = card.multiplier(for: category) * card.pointValueCents / 100
            return sum + (monthly * rate * 12)
        }
        let net = annualRewards - Double(card.annualFee)

        return ToolOutput(
            "\(card.name) ($\(card.annualFee)/yr, \(card.pointsProgram)): " +
            "annual rewards ≈ $\(String(format: "%.0f", annualRewards)), " +
            "net after fee = \(net >= 0 ? "+" : "")$\(String(format: "%.0f", net))"
        )
    }
}

---

## Wiring It Together — Multi-tool Session

```swift
@available(iOS 26.0, *)
func askFleece(question: String, cards: [CreditCard]) async -> String? {
    guard SystemLanguageModel.default.isAvailable else { return nil }

    let session = LanguageModelSession(
        tools: [
            GetWalletCardsTool(cards: cards),
            LookupMCCTool(),
            GetCardROITool(),
        ],
        instructions: """
        You are a concise credit card expert for the Fleece app.
        Always call get_wallet_cards before making recommendations.
        Extract spending amounts from the conversation — never ask the
        user to fill in a form. Keep answers under 50 words.
        Never invent card names, rates, or fees not returned by tools.
        """
    )

    let response = try? await session.respond(to: question)
    return response?.content
}
```

**Example interaction — spending info managed by model in context:**
```
User:  "I spend about $600/month on dining. Is Amex Gold worth it?"
Model: [calls get_wallet_cards]          → current wallet
       [calls get_card_roi(dining=600)]  → "$193 net after $325 fee"
       "Yes — at $600/mo dining you net +$193/yr after the fee.
        Worth it if you use the dining credits."

User:  "What about for groceries too? I spend $400/month."
Model: [calls get_card_roi(dining=600, groceries=400)]
       → "$385 net — model remembered $600 dining from earlier"
       "Even better — +$385/yr net with both categories."
```

The model carries `dining=$600` forward automatically — no profile screen, no settings, no stale data.

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
