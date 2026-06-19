import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStorage
    @Binding var selectedTab: AppTab

    private var budgetSnapshot: BudgetSnapshot {
        store.budgetSnapshot()
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var todaySubtitle: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var mealsToday: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return store.scheduledMeals.filter { $0.weekday == weekday }.count
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        HomeHeroBanner(
                            greeting: greeting,
                            subtitle: todaySubtitle
                        )
                        .padding(.horizontal, 16)

                        statsRow
                            .padding(.horizontal, 16)

                        if !store.dueRecurringTemplates.isEmpty {
                            HomeAlertWidget(
                                title: "Recurring list due",
                                message: "\(store.dueRecurringTemplates.count) template(s) ready to apply",
                                buttonTitle: "Apply"
                            ) {
                                if let template = store.dueRecurringTemplates.first {
                                    let count = store.applyTemplate(template)
                                    if count > 0 { FeedbackManager.success() }
                                }
                                selectedTab = .shop
                            }
                            .padding(.horizontal, 16)
                        }

                        if !store.pantryNeedsRestock.isEmpty {
                            HomeAlertWidget(
                                title: "Pantry needs restock",
                                message: "\(store.pantryNeedsRestock.count) items running low or empty",
                                buttonTitle: "Restock"
                            ) {
                                store.addMissingPantryToShoppingList()
                                FeedbackManager.success()
                                selectedTab = .shop
                            }
                            .padding(.horizontal, 16)
                        }

                        featureWidgets
                            .padding(.horizontal, 16)

                        HomeBudgetWidget(
                            spent: budgetSnapshot.weeklySpent,
                            limit: store.budgetSettings.weeklyLimit,
                            remaining: budgetSnapshot.weeklyRemaining
                        ) {
                            selectedTab = .track
                        }
                        .padding(.horizontal, 16)

                        quickActions
                            .padding(.horizontal, 16)

                        recentActivity
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationBarStyle()
        }
    }

    private var statsRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            HomeStatWidget(
                title: "List Items",
                value: "\(store.uncheckedItemCount)",
                iconName: "cart.fill",
                tint: Color("AppAccent")
            )
            HomeStatWidget(
                title: "Pantry Low",
                value: "\(store.pantryNeedsRestock.count)",
                iconName: "archivebox.fill",
                tint: Color("AppPrimary")
            )
            HomeStatWidget(
                title: "Day Streak",
                value: "\(store.streakDays)",
                iconName: "flame.fill",
                tint: Color("AppPrimary")
            )
            HomeStatWidget(
                title: "Achievements",
                value: unlockedCount,
                iconName: "star.fill",
                tint: Color("AppAccent")
            )
        }
    }

    private var unlockedCount: String {
        let count = Achievement.all.filter {
            store.achievementsUnlocked[$0.id] != nil || $0.isUnlocked(store)
        }.count
        return "\(count)/8"
    }

    private var featureWidgets: some View {
        VStack(spacing: 12) {
            SectionHeaderView(
                title: "Your Dashboard",
                subtitle: "Tap a widget to jump in",
                iconName: "square.grid.2x2.fill"
            )

            HomeFeatureWidget(
                title: "Shopping List",
                subtitle: "Items waiting at the store",
                value: "\(store.uncheckedItemCount)",
                imageName: "home_widget_shop"
            ) {
                selectedTab = .shop
            }

            HStack(spacing: 12) {
                HomeFeatureWidget(
                    title: "Pantry",
                    subtitle: "\(store.pantryItems.count) tracked items",
                    value: "\(store.pantryNeedsRestock.count) low",
                    imageName: "home_widget_pantry"
                ) {
                    selectedTab = .pantry
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                HomeFeatureWidget(
                    title: "Meals",
                    subtitle: "Scheduled for today",
                    value: "\(mealsToday)",
                    imageName: "home_widget_meals"
                ) {
                    selectedTab = .plan
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Quick Actions",
                subtitle: "One tap shortcuts",
                iconName: "bolt.fill"
            )
            HStack(spacing: 10) {
                HomeQuickAction(title: "Add Item", iconName: "plus.circle.fill") {
                    selectedTab = .shop
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                HomeQuickAction(title: "Store Trip", iconName: "map.fill") {
                    selectedTab = .shop
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                HomeQuickAction(title: "Log Purchase", iconName: "doc.text.fill") {
                    selectedTab = .track
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                HomeQuickAction(title: "Templates", iconName: "doc.on.doc.fill") {
                    selectedTab = .shop
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Recent Activity",
                subtitle: "Latest purchases",
                iconName: "clock.arrow.circlepath",
                trailing: store.purchaseHistory.isEmpty ? nil : "See all"
            )
            .onTapGesture {
                if !store.purchaseHistory.isEmpty {
                    FeedbackManager.lightTap()
                    selectedTab = .track
                }
            }

            if store.purchaseHistory.isEmpty {
                SurfaceCard(elevation: .flat) {
                    HStack(spacing: 12) {
                        IconBadge(iconName: "cart.fill", size: 40, tint: Color("AppTextSecondary"))
                        Text("No purchases logged yet")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Spacer()
                    }
                }
            } else {
                ForEach(store.purchaseHistory.prefix(3)) { purchase in
                    SurfaceCard(padding: 12, elevation: .flat) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(purchase.storeName)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text(purchase.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            Spacer()
                            Text(String(format: "$%.2f", purchase.totalSpent))
                                .font(.headline)
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                }
            }
        }
    }
}
