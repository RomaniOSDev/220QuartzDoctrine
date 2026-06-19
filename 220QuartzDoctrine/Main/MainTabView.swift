import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStorage
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            Color("AppBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab)
            }

            if let achievement = store.pendingAchievementBanner {
                AchievementBannerView(achievement: achievement) {
                    store.dismissAchievementBanner()
                }
                .padding(.top, 8)
                .zIndex(1)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                store.endSession()
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(selectedTab: $selectedTab)
        case .shop:
            ShopContainerView()
        case .pantry:
            PantryView()
        case .plan:
            MealPlannerView()
        case .track:
            TrackContainerView()
        case .more:
            MoreContainerView()
        }
    }
}
