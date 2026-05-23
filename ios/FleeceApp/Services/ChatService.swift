#if canImport(FoundationModels)
import FoundationModels
#endif
import Foundation

@MainActor
final class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isThinking = false
    @Published var error: String?

    private var cards: [CreditCard] = []

    // Store session as Any? — avoids @available on stored property
    private var _sessionAny: Any?

    func setCards(_ cards: [CreditCard]) {
        self.cards = cards
        // Do NOT reset the session here — the model calls GetWalletCardsTool
        // live on every relevant turn, so fresh wallet data is always fetched.
        // Destroying the session would wipe the conversation transcript.
    }

    func send(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(ChatMessage(user: text))
        isThinking = true
        error = nil

        if #available(iOS 26.0, *) {
            await sendWithAI(text)
        } else {
            messages.append(ChatMessage(
                answer: "AI chat requires iOS 26 with Apple Intelligence enabled.",
                followUp: nil
            ))
        }
        isThinking = false
    }

    func clear() {
        messages = []
        _sessionAny = nil
    }

    // MARK: - iOS 26

    @available(iOS 26.0, *)
    private var session: LanguageModelSession {
        if let s = _sessionAny as? LanguageModelSession { return s }
        let s = makeSession()
        _sessionAny = s
        return s
    }

    @available(iOS 26.0, *)
    private func makeSession() -> LanguageModelSession {
        let profile = SpendingProfile.load()
        let instructions = """
        You are a concise credit card expert for the Fleece app.
        Always call get_wallet_cards before making card recommendations.
        Use get_card_roi when the user asks about value or whether a card is worth it.
        Use get_transfer_partners when asked where to transfer points or which airlines a card partners with.
        Use get_point_valuations when asked how much points are worth or for the best redemption paths.
        Use get_application_rules when asked about eligibility, bonus cooldowns, or 5/24.
        Use get_card_benefits when asked about lounge access, trip delay, rental car insurance, or travel protections.
        Never invent card names, rates, or fees — only use values returned by tools.
        Keep answers under 40 words. Be direct and specific.
        \(profile.summary.isEmpty ? "" : "\nUser spending profile: \(profile.summary)")
        """
        return LanguageModelSession(
            tools: [
                GetWalletCardsTool(cards: cards),
                LookupMCCTool(),
                GetCardROITool(),
                GetTransferPartnersTool(),
                GetPointValuationsTool(),
                GetApplicationRulesTool(),
                GetCardBenefitsTool(),
            ],
            instructions: instructions
        )
    }

    @available(iOS 26.0, *)
    private func sendWithAI(_ text: String) async {
        guard SystemLanguageModel.default.isAvailable else {
            messages.append(ChatMessage(
                answer: "Enable Apple Intelligence in Settings → Apple Intelligence & Siri.",
                followUp: nil
            ))
            return
        }
        do {
            let response = try await session.respond(to: text, generating: FleeceResponse.self)
            let r = response.content

            // Persist spend data silently
            var profile = SpendingProfile.load()
            var updated = false
            if let v = r.diningMonthly    { profile.diningMonthly = v;    updated = true }
            if let v = r.groceriesMonthly { profile.groceriesMonthly = v; updated = true }
            if let v = r.travelMonthly    { profile.travelMonthly = v;    updated = true }
            if let v = r.gasMonthly       { profile.gasMonthly = v;       updated = true }
            if let v = r.preferredAirlinePartner, !v.isEmpty { profile.preferredAirlinePartner = v; updated = true }
            if let v = r.preferredHotelPartner,   !v.isEmpty { profile.preferredHotelPartner = v;   updated = true }
            if updated { profile.save() }

            messages.append(ChatMessage(
                answer: r.answer,
                recommendedCard: r.recommendedCard,
                effectiveRate: r.effectiveRate,
                followUp: r.followUp
            ))
        } catch {
            self.error = error.localizedDescription
            messages.append(ChatMessage(answer: "Something went wrong. Try again.", followUp: nil))
        }
    }
}
