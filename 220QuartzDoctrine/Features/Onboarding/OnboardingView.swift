import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let iconName: String
    let accent: Color
    let features: [String]
    let heroStyle: OnboardingHeroStyle
}

private enum OnboardingHeroStyle {
    case shopping
    case pantry
    case tracking
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var currentPage = 0
    @State private var heroScale: CGFloat = 0.88
    @State private var heroOpacity: Double = 0
    @State private var cardOffset: CGFloat = 24

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            headline: "Shop Smarter",
            description: "Build store-specific lists grouped by aisle. Check items off in Trip Mode while you walk the store.",
            iconName: "cart.fill",
            accent: Color("AppPrimary"),
            features: ["Aisle Groups", "Multi-Store", "Trip Mode"],
            heroStyle: .shopping
        ),
        OnboardingPage(
            id: 1,
            headline: "Stay Stocked",
            description: "Track pantry levels, plan weekly meals, and apply templates to restock your list in one tap.",
            iconName: "archivebox.fill",
            accent: Color("AppAccent"),
            features: ["Pantry", "Meal Planner", "Templates"],
            heroStyle: .pantry
        ),
        OnboardingPage(
            id: 2,
            headline: "Know Your Spend",
            description: "Set budget envelopes, log purchases, and compare prices over time to spend with confidence.",
            iconName: "chart.bar.fill",
            accent: Color("AppPrimary"),
            features: ["Budget", "Insights", "Price Memory"],
            heroStyle: .tracking
        )
    ]

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        onboardingPage(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                pageIndicator
                    .padding(.bottom, 20)

                PrimaryButton(
                    title: currentPage < pages.count - 1 ? "Next" : "Get Started",
                    iconName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
                ) {
                    advance()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: currentPage) { _ in
            playEntranceAnimation()
        }
        .onAppear {
            playEntranceAnimation()
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                OnboardingHeroView(style: page.heroStyle, iconName: page.iconName, accent: page.accent)
                    .scaleEffect(heroScale)
                    .opacity(heroOpacity)
                    .frame(height: 240)
                    .padding(.top, 32)

                SurfaceCard(elevation: .floating) {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            IconBadge(iconName: page.iconName, size: 44, tint: page.accent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(page.headline)
                                    .font(.title2.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("Step \(page.id + 1) of \(pages.count)")
                                    .font(.caption.bold())
                                    .foregroundStyle(page.accent)
                            }
                            Spacer(minLength: 0)
                        }

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 8) {
                            ForEach(page.features, id: \.self) { feature in
                                TagPill(text: feature, tint: page.accent)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 24)
                .offset(y: cardOffset)
                .opacity(heroOpacity)
            }
            .padding(.bottom, 16)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Capsule()
                    .fill(
                        page.id == currentPage
                            ? AppGradients.primaryButton
                            : LinearGradient(
                                colors: [Color("AppSurface"), Color("AppBackground").opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                Color("AppAccent").opacity(page.id == currentPage ? 0.35 : 0.15),
                                lineWidth: 1
                            )
                    )
                    .frame(width: page.id == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
            }
        }
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            FeedbackManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            FeedbackManager.mediumImpact()
            store.completeOnboarding()
        }
    }

    private func playEntranceAnimation() {
        heroScale = 0.88
        heroOpacity = 0
        cardOffset = 24
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            heroScale = 1
            heroOpacity = 1
            cardOffset = 0
        }
    }
}

// MARK: - Hero

private struct OnboardingHeroView: View {
    let style: OnboardingHeroStyle
    let iconName: String
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.28), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 110
                    )
                )
                .frame(width: 220, height: 220)

            switch style {
            case .shopping:
                shoppingHero
            case .pantry:
                pantryHero
            case .tracking:
                trackingHero
            }
        }
    }

    private var shoppingHero: some View {
        ZStack {
            heroCard(width: 200, height: 150, elevation: .floating) {
                VStack(spacing: 10) {
                    HStack {
                        IconBadge(iconName: iconName, size: 52, tint: accent)
                        Spacer()
                        TagPill(text: "3 items", tint: Color("AppAccent"))
                    }
                    VStack(spacing: 6) {
                        miniListRow(checked: true, label: "Milk")
                        miniListRow(checked: false, label: "Bread")
                        miniListRow(checked: false, label: "Eggs")
                    }
                }
            }

            satelliteCard(width: 88, height: 72, elevation: .raised) {
                VStack(spacing: 4) {
                    Image(systemName: "map.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                    Text("Trip")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .offset(x: 92, y: -58)

            satelliteCard(width: 72, height: 56, elevation: .raised) {
                Image(systemName: "building.2.fill")
                    .font(.title3)
                    .foregroundStyle(accent)
            }
            .offset(x: -96, y: 64)
        }
    }

    private var pantryHero: some View {
        ZStack {
            heroCard(width: 200, height: 150, elevation: .floating) {
                VStack(spacing: 10) {
                    HStack {
                        IconBadge(iconName: iconName, size: 52, tint: accent)
                        Spacer()
                        TagPill(text: "In Stock", tint: Color("AppAccent"))
                    }
                    HStack(spacing: 8) {
                        statusChip("Low", tint: Color("AppPrimary"))
                        statusChip("Empty", tint: Color("AppPrimary"))
                    }
                    miniListRow(checked: false, label: "Add to list")
                }
            }

            satelliteCard(width: 88, height: 72, elevation: .raised) {
                VStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.title3)
                        .foregroundStyle(Color("AppPrimary"))
                    Text("Meals")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .offset(x: 92, y: -58)

            satelliteCard(width: 72, height: 56, elevation: .raised) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.title3)
                    .foregroundStyle(accent)
            }
            .offset(x: -96, y: 64)
        }
    }

    private var trackingHero: some View {
        ZStack {
            heroCard(width: 200, height: 150, elevation: .floating) {
                VStack(spacing: 12) {
                    HStack {
                        IconBadge(iconName: iconName, size: 52, tint: accent)
                        Spacer()
                        Text("$124")
                            .font(.headline.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(AppGradients.surfaceInset)
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("AppAccent"), Color("AppPrimary")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * 0.62)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        TagPill(text: "Weekly", tint: accent)
                        TagPill(text: "Groceries", tint: Color("AppAccent"))
                    }
                }
            }

            satelliteCard(width: 88, height: 72, elevation: .raised) {
                VStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                    Text("Prices")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .offset(x: 92, y: -58)

            satelliteCard(width: 72, height: 56, elevation: .raised) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(accent)
            }
            .offset(x: -96, y: 64)
        }
    }

    private func heroCard<Content: View>(
        width: CGFloat,
        height: CGFloat,
        elevation: CardElevation,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DepthSurface(cornerRadius: 18, padding: 14, elevation: elevation, content: content)
            .frame(width: width, height: height)
    }

    private func satelliteCard<Content: View>(
        width: CGFloat,
        height: CGFloat,
        elevation: CardElevation,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DepthSurface(cornerRadius: 14, padding: 10, elevation: elevation, content: content)
            .frame(width: width, height: height)
    }

    private func miniListRow(checked: Bool, label: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(
                        checked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.4),
                        lineWidth: 1.5
                    )
                    .frame(width: 16, height: 16)
                if checked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(
                    checked ? Color("AppTextSecondary") : Color("AppTextPrimary")
                )
                .strikethrough(checked, color: Color("AppTextSecondary"))
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            ListCellBackground(cornerRadius: 10, checked: checked)
        }
    }

    private func statusChip(_ label: String, tint: Color) -> some View {
        Text(label)
            .font(.caption2.bold())
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.2), tint.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .frame(maxWidth: .infinity)
    }
}
