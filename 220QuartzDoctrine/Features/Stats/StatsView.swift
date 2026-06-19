import SwiftUI

struct StatsView: View {
    var embedded = false
    @EnvironmentObject private var store: AppStorage

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if embedded { content } else { NavigationStack { content } }
        }
    }

    private var content: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 16) {
                    statsGrid
                    SectionHeaderView(
                        title: "Achievements",
                        subtitle: "\(unlockedCount) of 8 unlocked",
                        iconName: "star.fill"
                    )
                    achievementsGrid
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .modifier(EmbeddedNavigationModifier(embedded: embedded, title: "Achievements"))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MetricTile(title: "Items Created", value: "\(store.itemsCreated)", iconName: "bag.fill")
            MetricTile(title: "Sessions", value: "\(store.totalSessionsCompleted)", iconName: "clock.fill")
            MetricTile(title: "Streak", value: "\(store.streakDays)d", iconName: "flame.fill", accent: Color("AppPrimary"))
            MetricTile(title: "Pantry", value: "\(store.pantryItems.count)", iconName: "archivebox.fill")
        }
    }

    private var unlockedCount: Int {
        Achievement.all.filter { store.achievementsUnlocked[$0.id] != nil || $0.isUnlocked(store) }.count
    }

    private var achievementsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Achievement.all) { achievement in
                AchievementCell(
                    achievement: achievement,
                    isUnlocked: achievement.isUnlocked(store)
                )
            }
        }
    }
}
