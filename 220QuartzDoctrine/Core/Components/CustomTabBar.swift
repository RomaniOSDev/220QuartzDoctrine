import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case shop
    case pantry
    case plan
    case track
    case more

    var title: String {
        switch self {
        case .home: return "Home"
        case .shop: return "Shop"
        case .pantry: return "Pantry"
        case .plan: return "Plan"
        case .track: return "Track"
        case .more: return "More"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .shop: return "cart.fill"
        case .pantry: return "archivebox.fill"
        case .plan: return "fork.knife"
        case .track: return "chart.bar.fill"
        case .more: return "ellipsis.circle.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    FeedbackManager.lightTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color("AppSurface"), Color("AppBackground")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color("AppAccent").opacity(0.18))
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppGradients.primaryButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
                            )
                            .frame(width: 44, height: 32)
                    }
                    Image(systemName: tab.iconName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                }
                Text(tab.title)
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.92 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 48)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}
