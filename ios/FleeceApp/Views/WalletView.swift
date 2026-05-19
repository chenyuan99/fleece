import SwiftUI

struct WalletView: View {
    @EnvironmentObject var appState: AppState

    var walletCards: [CreditCard]   { appState.cards.filter(\.isInWallet) }
    var availableCards: [CreditCard] { appState.cards.filter { !$0.isInWallet } }

    var body: some View {
        NavigationStack {
            List {
                if !walletCards.isEmpty {
                    Section("My Wallet (\(walletCards.count))") {
                        ForEach(walletCards) { card in
                            CardRowView(card: card)
                        }
                    }
                }

                Section("Add to Wallet") {
                    ForEach(availableCards) { card in
                        CardRowView(card: card)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Wallet")
            .overlay {
                if appState.cards.isEmpty {
                    ContentUnavailableView("No Cards", systemImage: "creditcard")
                }
            }
        }
    }
}

struct CardRowView: View {
    let card: CreditCard
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 14) {
            // Mini card visual
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

            VStack(alignment: .leading, spacing: 3) {
                Text(card.name)
                    .font(.subheadline).fontWeight(.medium)
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

    private var topCategorySummary: String {
        let top = card.categoryMultipliers
            .sorted { $0.value > $1.value }
            .prefix(2)
            .map { "\(Int($0.value))x \($0.key)" }
            .joined(separator: " · ")
        if top.isEmpty {
            return "\(String(format: "%.1f", card.baseMultiplier))x everywhere"
        }
        return top
    }
}
