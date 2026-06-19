import SwiftUI

enum CardElevation {
    case flat
    case raised
    case floating
    case hero

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 5
        case .floating: return 8
        case .hero: return 10
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 3
        case .floating: return 5
        case .hero: return 6
        }
    }
}

enum AppGradients {
    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground").opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceInset: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.55),
                Color("AppSurface").opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentHighlight: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent").opacity(0.35), Color("AppAccent").opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var borderGlow: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent").opacity(0.32), Color("AppAccent").opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var topGloss: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.1), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct DepthCardBackground: View {
    var cornerRadius: CGFloat = 16
    var showBorder: Bool = true
    var inset: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(inset ? AppGradients.surfaceInset : AppGradients.surface)
            .overlay {
                if showBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppGradients.borderGlow, lineWidth: 1)
                }
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppGradients.topGloss)
                    .frame(height: max(cornerRadius * 0.55, 10))
                    .clipShape(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
                    .allowsHitTesting(false)
            }
    }
}

struct DepthModifier: ViewModifier {
    let elevation: CardElevation
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if elevation == .flat {
            content
        } else {
            content
                .compositingGroup()
                .shadow(
                    color: Color("AppBackground").opacity(0.55),
                    radius: elevation.shadowRadius,
                    x: 0,
                    y: elevation.shadowY
                )
        }
    }
}

extension View {
    func depth(_ elevation: CardElevation, cornerRadius: CGFloat = 16) -> some View {
        modifier(DepthModifier(elevation: elevation, cornerRadius: cornerRadius))
    }
}

struct DepthSurface<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    var elevation: CardElevation = .raised
    var showBorder: Bool = true
    var inset: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                DepthCardBackground(
                    cornerRadius: cornerRadius,
                    showBorder: showBorder,
                    inset: inset
                )
            }
            .depth(elevation, cornerRadius: cornerRadius)
    }
}
