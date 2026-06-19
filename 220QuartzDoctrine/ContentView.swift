import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStorage.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
