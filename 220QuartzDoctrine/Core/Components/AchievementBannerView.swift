import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -140

    var body: some View {
        SurfaceCard(padding: 14, elevation: .floating) {
            HStack(spacing: 14) {
                IconBadge(iconName: achievement.iconName, size: 44, tint: Color("AppAccent"))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Achievement Unlocked")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(achievement.description)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    offset = -140
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}
