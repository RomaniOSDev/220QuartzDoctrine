import SwiftUI

struct HomeHeroBanner: View {
    let greeting: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.1), Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppGradients.borderGlow, lineWidth: 1)
        )
        .depth(.hero, cornerRadius: 20)
    }
}

struct HomeStatWidget: View {
    let title: String
    let value: String
    let iconName: String
    var tint: Color = Color("AppAccent")

    var body: some View {
        SurfaceCard(padding: 12, elevation: .raised) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: iconName)
                    .font(.caption.bold())
                    .foregroundStyle(tint)
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct HomeFeatureWidget: View {
    let title: String
    let subtitle: String
    let value: String
    let imageName: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [Color.clear, Color("AppBackground").opacity(0.88)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(value)
                        .font(.title.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(12)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppGradients.borderGlow, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .depth(.floating, cornerRadius: 18)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}

struct HomeBudgetWidget: View {
    let spent: Double
    let limit: Double
    let remaining: Double
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            SurfaceCard(elevation: .floating) {
                HStack(spacing: 14) {
                    ZStack {
                        Image("home_widget_budget")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color("AppBackground").opacity(0.6)))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Weekly Budget")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(String(format: "$%.0f left", remaining))
                            .font(.title3.bold())
                            .foregroundStyle(spent > limit ? Color("AppPrimary") : Color("AppAccent"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(String(format: "Spent $%.0f of $%.0f", spent, limit))
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var progress: CGFloat {
        guard limit > 0 else { return 0 }
        return CGFloat(min(spent / limit, 1))
    }
}

struct HomeQuickAction: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            VStack(spacing: 8) {
                IconBadge(iconName: iconName, size: 44, tint: Color("AppPrimary"))
                Text(title)
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                DepthCardBackground(cornerRadius: 14)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HomeAlertWidget: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        SurfaceCard(elevation: .floating) {
            HStack(alignment: .center, spacing: 12) {
                IconBadge(iconName: "bell.badge.fill", size: 40, tint: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)

                Button(buttonTitle, action: {
                    FeedbackManager.mediumImpact()
                    action()
                })
                .font(.caption.bold())
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppGradients.accentHighlight)
                        .overlay(Capsule().stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1))
                )
                .layoutPriority(0)
            }
        }
    }
}
