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

Four tools — all offline, all grounded in local data, zero hallucination risk on facts.

### Profile persistence architecture

Spending data (dining, groceries, travel, gas, other monthly spend) is stored in
`UserDefaults` — the same pattern as `fleece profile` in the CLI (which uses SQLite).

**Session startup:** the stored profile is injected directly into the system prompt so
the model starts every session already knowing your spend. No tool call needed to read it,
no questions asked on session 2+.

**During conversation:** when the user mentions a spending amount, the model silently
calls `UpdateSpendingProfileTool` to persist it. Next session it's already in the
system prompt.

```
Session 1 — learning:
  User:  "I spend $600/month on dining"
  Model: [calls update_spending_profile(diningMonthly: 600)]  ← saved
  Model: "Got it — at $600/mo dining, Amex Gold nets +$193/yr."

Session 2 — already knows:
  System: "Spending profile: dining=$600/mo"  ← injected from UserDefaults
  User:   "Is Amex Gold worth it?"
  Model:  [calls get_card_roi(cardName: "Amex Gold", diningMonthly: 600)]
  Model:  "Yes — +$193/yr net after the $325 fee."  ← no questions asked
```

A **Profile screen in Settings** lets the user view and manually edit stored values —
equivalent to `fleece profile show` and `fleece profile set` in the CLI.

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

### `UpdateSpendingProfileTool`
Called silently by the model when the user mentions a spending amount. Persists to `UserDefaults` so every future session starts with the correct context already loaded.

```swift
@available(iOS 26.0, *)
struct UpdateSpendingProfileTool: Tool {
    static let name = "update_spending_profile"
    static let description = """
        Save spending amounts mentioned by the user to their persistent profile.
        Call this whenever the user states or updates a monthly spend figure.
        Only include fields the user explicitly mentioned — leave others unchanged.
        """

    @Parameter(description: "Monthly dining spend in USD, if mentioned")
    var diningMonthly: Double?
    @Parameter(description: "Monthly grocery spend in USD, if mentioned")
    var groceriesMonthly: Double?
    @Parameter(description: "Monthly travel spend in USD, if mentioned")
    var travelMonthly: Double?
    @Parameter(description: "Monthly gas spend in USD, if mentioned")
    var gasMonthly: Double?
    @Parameter(description: "Monthly other spend in USD, if mentioned")
    var otherMonthly: Double?

    func call(context: ToolContext) async throws -> ToolOutput {
        var profile = SpendingProfile.load()
        if let v = diningMonthly     { profile.diningMonthly = v }
        if let v = groceriesMonthly  { profile.groceriesMonthly = v }
        if let v = travelMonthly     { profile.travelMonthly = v }
        if let v = gasMonthly        { profile.gasMonthly = v }
        if let v = otherMonthly      { profile.otherMonthly = v }
        profile.save()
        return ToolOutput("Spending profile updated: \(profile.summary)")
    }
}

// UserDefaults-backed profile — mirrors fleece profile in the CLI
struct SpendingProfile: Codable {
    var diningMonthly:    Double = 0
    var groceriesMonthly: Double = 0
    var travelMonthly:    Double = 0
    var gasMonthly:       Double = 0
    var otherMonthly:     Double = 0

    static func load() -> SpendingProfile {
        guard let data = UserDefaults.standard.data(forKey: "spendingProfile"),
              let profile = try? JSONDecoder().decode(SpendingProfile.self, from: data)
        else { return SpendingProfile() }
        return profile
    }

    func save() {
        let data = try? JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: "spendingProfile")
    }

    var isEmpty: Bool {
        diningMonthly == 0 && groceriesMonthly == 0 &&
        travelMonthly == 0 && gasMonthly == 0 && otherMonthly == 0
    }

    var summary: String {
        var parts: [String] = []
        if diningMonthly    > 0 { parts.append("dining=$\(Int(diningMonthly))/mo") }
        if groceriesMonthly > 0 { parts.append("groceries=$\(Int(groceriesMonthly))/mo") }
        if travelMonthly    > 0 { parts.append("travel=$\(Int(travelMonthly))/mo") }
        if gasMonthly       > 0 { parts.append("gas=$\(Int(gasMonthly))/mo") }
        if otherMonthly     > 0 { parts.append("other=$\(Int(otherMonthly))/mo") }
        return parts.isEmpty ? "no spending data yet" : parts.joined(separator: ", ")
    }
}
```

---

## Wiring It Together — Multi-tool Session

```swift
@available(iOS 26.0, *)
func makeSession(cards: [CreditCard]) -> LanguageModelSession {
    let profile = SpendingProfile.load()

    let instructions = """
    You are a concise credit card expert for the Fleece app.
    Always call get_wallet_cards before making recommendations.
    When the user mentions a spending amount, call update_spending_profile
    to persist it — do this silently without telling the user.
    Never invent card names, rates, or fees not returned by tools.
    Keep answers under 50 words.
    \(profile.isEmpty ? "" : "\nUser's spending profile: \(profile.summary)")
    """

    return LanguageModelSession(
        tools: [
            GetWalletCardsTool(cards: cards),
            LookupMCCTool(),
            GetCardROITool(),
            UpdateSpendingProfileTool(),
        ],
        instructions: instructions
    )
}
// Session is created once per chat tab open and reused across turns.
// SpendingProfile persists to UserDefaults between app launches.
```
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
