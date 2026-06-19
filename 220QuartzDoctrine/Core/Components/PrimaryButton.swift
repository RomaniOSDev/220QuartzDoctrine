import SwiftUI

struct PrimaryButton: View {
    let title: String
    var iconName: String? = nil
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let iconName {
                    Image(systemName: iconName)
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppGradients.primaryButton)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppGradients.topGloss)
                            .frame(height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .depth(.floating, cornerRadius: 14)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isPressed = false } }
        )
        .frame(minHeight: 44)
    }
}
