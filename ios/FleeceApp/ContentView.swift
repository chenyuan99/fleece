import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem { Label("Nearby", systemImage: "location.fill") }
                .tag(AppState.Tab.home)

            WalletView()
                .tabItem { Label("Wallet", systemImage: "creditcard.fill") }
                .tag(AppState.Tab.wallet)

            AskView()
                .tabItem { Label("Ask", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(AppState.Tab.ask)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(AppState.Tab.settings)
        }
        .tint(.indigo)
        .sheet(isPresented: $appState.showRecommendationSheet) {
            if let place = appState.currentPlace {
                RecommendationsSheetView(
                    place: place,
                    recommendations: appState.recommendations
                )
            }
        }
    }
}
