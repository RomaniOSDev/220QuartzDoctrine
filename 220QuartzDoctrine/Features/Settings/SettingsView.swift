import SwiftUI

struct SettingsView: View {
    var embedded = false
    @EnvironmentObject private var store: AppStorage
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

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
                    settingsCard
                    versionFooter
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .modifier(EmbeddedNavigationModifier(embedded: embedded, title: "Settings"))
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { FeedbackManager.lightTap() }
            Button("Reset", role: .destructive) {
                FeedbackManager.mediumImpact()
                store.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your shopping lists, purchases, and progress. This action cannot be undone.")
        }
    }

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Your Stats",
                subtitle: "Activity overview",
                iconName: "chart.line.uptrend.xyaxis"
            )
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                MetricTile(title: "Items", value: "\(store.itemsCreated)", iconName: "bag.fill")
                MetricTile(title: "Minutes", value: "\(store.totalMinutesUsed)", iconName: "clock.fill")
                MetricTile(title: "Streak", value: "\(store.streakDays)d", iconName: "flame.fill", accent: Color("AppPrimary"))
                MetricTile(title: "Sessions", value: "\(store.totalSessionsCompleted)", iconName: "arrow.triangle.2.circlepath")
            }
        }
    }

    private var settingsCard: some View {
        SurfaceCard(padding: 0, elevation: .raised) {
            VStack(spacing: 0) {
                Button {
                    FeedbackManager.lightTap()
                    AppReview.rateApp()
                } label: {
                    SettingsRowCell(title: "Rate Us", iconName: "star.fill")
                }
                .buttonStyle(.plain)

                Divider().background(Color("AppAccent").opacity(0.12)).padding(.leading, 68)

                Button {
                    FeedbackManager.lightTap()
                    AppLink.privacyPolicy.open()
                } label: {
                    SettingsRowCell(title: "Privacy", iconName: "hand.raised.fill")
                }
                .buttonStyle(.plain)

                Divider().background(Color("AppAccent").opacity(0.12)).padding(.leading, 68)

                Button {
                    FeedbackManager.lightTap()
                    AppLink.termsOfService.open()
                } label: {
                    SettingsRowCell(title: "Terms", iconName: "doc.text.fill")
                }
                .buttonStyle(.plain)

                Divider().background(Color("AppAccent").opacity(0.12)).padding(.leading, 68)

                Button {
                    FeedbackManager.lightTap()
                    showResetAlert = true
                } label: {
                    SettingsRowCell(
                        title: "Reset All Data",
                        iconName: "trash.fill",
                        isDestructive: true,
                        showChevron: false
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}
