import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
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
            }
            .navigationTitle("Settings")
        }
    }
}
