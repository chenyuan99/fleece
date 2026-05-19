import SwiftUI
import PassKit

struct WalletView: View {
    @EnvironmentObject var appState: AppState

    var walletCards: [CreditCard]    { appState.cards.filter(\.isInWallet) }
    var availableCards: [CreditCard] { appState.cards.filter { !$0.isInWallet && !appState.suggestedCards.map(\.id).contains($0.id) } }

    var body: some View {
        NavigationStack {
            List {
                // ── Detected networks banner ─────────────────────────
                if !appState.detectedNetworks.isEmpty {
                    Section {
                        NetworkDetectionBanner(networks: appState.detectedNetworks)
                    }
                }

                // ── Suggested from Apple Wallet ───────────────────────
                if !appState.suggestedCards.isEmpty {
                    Section {
                        ForEach(appState.suggestedCards) { card in
                            CardRowView(card: card, style: .suggested)
                        }
                    } header: {
                        Label("Detected in Apple Wallet", systemImage: "wallet.pass.fill")
                    } footer: {
                        Text("These cards match payment networks found in your Apple Wallet. Tap + to confirm.")
                            .font(.caption)
                    }
                }

                // ── My wallet ─────────────────────────────────────────
                if !walletCards.isEmpty {
                    Section("My Wallet (\(walletCards.count))") {
                        ForEach(walletCards) { card in
                            CardRowView(card: card, style: .inWallet)
                        }
                    }
                }

                // ── All other cards ───────────────────────────────────
                if !availableCards.isEmpty {
                    Section("All Cards") {
                        ForEach(availableCards) { card in
                            CardRowView(card: card, style: .available)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.runWalletDetection()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Network Detection Banner

struct NetworkDetectionBanner: View {
    let networks: Set<PKPaymentNetwork>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "wave.3.right.circle.fill")
                    .foregroundColor(.indigo)
                Text("Networks detected in Apple Wallet")
                    .font(.subheadline).fontWeight(.semibold)
            }
            HStack(spacing: 8) {
                ForEach(Array(networks), id: \.rawValue) { network in
                    HStack(spacing: 4) {
                        Text(network.emoji).font(.caption)
                        Text(network.displayName)
                            .font(.caption).fontWeight(.medium)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.indigo.opacity(0.1))
                    .foregroundColor(.indigo)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Card Row

enum CardRowStyle { case suggested, inWallet, available }

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
                    if style == .suggested {
                        Label("Detected", systemImage: "wave.3.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.indigo.opacity(0.1))
                            .clipShape(Capsule())
                    }
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
