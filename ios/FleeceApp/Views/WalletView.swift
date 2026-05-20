import SwiftUI

struct WalletView: View {
    @EnvironmentObject var appState: AppState

    var walletCards: [CreditCard]    { appState.cards.filter(\.isInWallet) }
    var availableCards: [CreditCard] { appState.cards.filter { !$0.isInWallet && !appState.suggestedCards.map(\.id).contains($0.id) } }

    var body: some View {
        NavigationStack {
            List {
                // Empty state banner — shown until at least one card is added
                if walletCards.isEmpty {
                    Section {
                        EmptyWalletBanner()
                    }
                } else {
                    Section("My Wallet (\(walletCards.count))") {
                        ForEach(walletCards) { card in
                            CardRowView(card: card, style: .inWallet)
                        }
                    }
                }

                // Suggested cards (detected via Apple Wallet networks) shown first,
                // then remaining cards — no detection UI exposed to the user.
                let addSection = appState.suggestedCards + availableCards
                if !addSection.isEmpty {
                    Section("Add to Wallet") {
                        ForEach(addSection) { card in
                            CardRowView(card: card, style: .available)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Wallet")
        }
    }
}

// MARK: - Empty State

struct EmptyWalletBanner: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Your wallet is empty")
                    .font(.headline)
                Text("Add your cards below to get\npersonalised recommendations at every store.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Card Row

enum CardRowStyle { case inWallet, available }

struct CardRowView: View {
    let card: CreditCard
    var style: CardRowStyle = .available
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 14) {
            miniCard

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(card.name)
                        .font(.subheadline).fontWeight(.medium)
                }
                HStack(spacing: 6) {
                    Text(card.issuer)
                        .font(.caption).foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(card.annualFee == 0 ? "No annual fee" : "$\(card.annualFee)/yr")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Text(topCategorySummary)
                    .font(.caption2)
                    .foregroundColor(.indigo)
            }

            Spacer()

            Button {
                appState.toggleWallet(card: card)
            } label: {
                Image(systemName: card.isInWallet ? "minus.circle.fill" : "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(card.isInWallet ? .red.opacity(0.8) : .green)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private var miniCard: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(card.color)
            .frame(width: 52, height: 34)
            .shadow(color: card.color.opacity(0.3), radius: 4, y: 2)
            .overlay(
                VStack(spacing: 1) {
                    Text(card.issuer == "American Express" ? "Amex" : card.issuer)
                        .font(.system(size: 6, weight: .semibold))
                        .foregroundColor(card.labelColor.opacity(0.8))
                    Text(card.name.components(separatedBy: " ").first ?? "")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(card.labelColor)
                        .lineLimit(1)
                }
            )
    }

    private var topCategorySummary: String {
        let top = card.categoryMultipliers
            .sorted { $0.value > $1.value }
            .prefix(2)
            .map { "\(Int($0.value))x \($0.key)" }
            .joined(separator: " · ")
        return top.isEmpty
            ? "\(String(format: "%.1f", card.baseMultiplier))x everywhere"
            : top
    }
}
