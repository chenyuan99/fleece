import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

struct SettingsView: View {

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    // Evaluated once at render time — safe on all OS versions
    private var aiStatus: AIStatus {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable ? .enabled : .disabled
        }
        return .unsupported
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Location data", value: "Apple MapKit (free)")
                    LabeledContent("Cards database", value: "9 major US issuers")
                }

                Section {
                    HStack {
                        Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                        Text("No API key required")
                    }
                    HStack {
                        Image(systemName: "dollarsign.circle.fill").foregroundColor(.green)
                        Text("Zero per-request cost")
                    }
                    HStack {
                        Image(systemName: "lock.shield.fill").foregroundColor(.blue)
                        Text("All searches stay on-device")
                    }
                } header: {
                    Text("Privacy & Cost")
                } footer: {
                    Text("Place detection uses Apple's MapKit framework — no data leaves your device to a third-party API.")
                }

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: aiStatus.icon)
                            .foregroundColor(aiStatus.color)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(aiStatus.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(aiStatus.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("Apple Intelligence")
                } footer: {
                    Text(aiStatus.footer)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - AI Status

private enum AIStatus {
    case enabled, disabled, unsupported

    var icon: String {
        switch self {
        case .enabled:     return "sparkles"
        case .disabled:    return "sparkles.slash"
        case .unsupported: return "xmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .enabled:     return .indigo
        case .disabled:    return .orange
        case .unsupported: return .gray
        }
    }

    var title: String {
        switch self {
        case .enabled:     return "Apple Intelligence is active"
        case .disabled:    return "Apple Intelligence is off"
        case .unsupported: return "Not available on this device"
        }
    }

    var subtitle: String {
        switch self {
        case .enabled:     return "AI card explanations enabled"
        case .disabled:    return "AI card explanations disabled"
        case .unsupported: return "Requires iOS 26 + Apple Intelligence"
        }
    }

    var footer: String {
        switch self {
        case .enabled:
            return "Fleece uses the on-device language model to generate one-sentence explanations of why a card is the best pick at each merchant. No data leaves your device."
        case .disabled:
            return "Enable Apple Intelligence in Settings → Apple Intelligence & Siri to activate AI-powered card explanations."
        case .unsupported:
            return "AI card explanations require an iPhone 15 Pro or later running iOS 26 with Apple Intelligence enabled."
        }
    }
}
