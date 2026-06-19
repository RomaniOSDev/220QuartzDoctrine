import SwiftUI

struct SurfaceCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    var elevation: CardElevation = .raised
    var showBorder: Bool = true
    var inset: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        DepthSurface(
            cornerRadius: cornerRadius,
            padding: padding,
            elevation: elevation,
            showBorder: showBorder,
            inset: inset,
            content: content
        )
    }
}

struct IconBadge: View {
    let iconName: String
    var size: CGFloat = 44
    var tint: Color = Color("AppPrimary")

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.42), tint.opacity(0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(tint.opacity(0.28), lineWidth: 1)
                )
                .frame(width: size, height: size)
            Image(systemName: iconName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(tint)
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var iconName: String?
    var trailing: String?

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if let iconName {
                IconBadge(iconName: iconName, size: 36, tint: Color("AppAccent"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(AppGradients.accentHighlight)
                            .overlay(Capsule().stroke(Color("AppAccent").opacity(0.25), lineWidth: 1))
                    )
            }
        }
    }
}

struct EmptyStateView: View {
    let iconName: String
    let title: String
    var message: String
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 48)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppPrimary").opacity(0.22), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                IconBadge(iconName: iconName, size: 72, tint: Color("AppPrimary"))
            }
            .scaleEffect(appeared ? 1 : 0.88)
            .opacity(appeared ? 1 : 0.5)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(message)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let actionTitle, let action {
                Button(action: {
                    FeedbackManager.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppGradients.primaryButton)
                                .overlay(Capsule().stroke(Color("AppAccent").opacity(0.3), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
                .depth(.raised, cornerRadius: 20)
            }
            Spacer(minLength: 48)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                appeared = true
            }
        }
    }
}

struct ToastBanner: View {
    let message: String
    var iconName: String = "checkmark.circle.fill"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(Color("AppTextPrimary"))
            Text(message)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(AppGradients.primaryButton)
                .overlay(Capsule().stroke(Color("AppAccent").opacity(0.35), lineWidth: 1))
        )
        .depth(.floating, cornerRadius: 24)
    }
}

struct TagPill: View {
    let text: String
    var tint: Color = Color("AppAccent")

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.22), tint.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Capsule().stroke(tint.opacity(0.2), lineWidth: 0.5))
            )
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    var iconName: String?
    var accent: Color = Color("AppAccent")

    var body: some View {
        SurfaceCard(padding: 14, elevation: .raised) {
            HStack(spacing: 12) {
                if let iconName {
                    IconBadge(iconName: iconName, size: 40, tint: accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(value)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(
                            isSelected
                                ? AppGradients.primaryButton
                                : LinearGradient(
                                    colors: [Color("AppSurface"), Color("AppBackground").opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color("AppAccent").opacity(isSelected ? 0.35 : 0.18), lineWidth: 1)
                        )
                }
        }
        .buttonStyle(.plain)
        .depth(isSelected ? .raised : .flat, cornerRadius: 20)
    }
}

struct AddChipButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(AppGradients.surface)
                        .overlay(Circle().stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1))
                }
        }
        .buttonStyle(.plain)
    }
}

struct StyledSegmentedPicker: View {
    @Binding var selection: Int
    let labels: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) { selection = index }
                } label: {
                    Text(label)
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .foregroundStyle(selection == index ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selection == index {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppGradients.primaryButton)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color("AppAccent").opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            DepthCardBackground(cornerRadius: 14)
        }
        .depth(.raised, cornerRadius: 14)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct FormSheetContainer<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    content()
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FormFieldCard<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            content()
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            DepthCardBackground(cornerRadius: 12, inset: true)
        }
    }
}

struct ListCellBackground: View {
    var cornerRadius: CGFloat = 16
    var highlighted: Bool = false
    var checked: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                highlighted
                    ? LinearGradient(
                        colors: [Color("AppAccent").opacity(0.18), Color("AppAccent").opacity(0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : AppGradients.surface
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        Color("AppAccent").opacity(checked ? 0.38 : 0.14),
                        lineWidth: checked ? 1.5 : 1
                    )
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppGradients.topGloss)
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
    }
}

struct AppNavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func appNavigationBarStyle() -> some View {
        modifier(AppNavigationBarStyle())
    }
}
