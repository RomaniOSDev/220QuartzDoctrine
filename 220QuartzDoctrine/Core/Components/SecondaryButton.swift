import SwiftUI

struct SecondaryButton: View {
    let title: String
    let iconName: String?
    let action: () -> Void

    @State private var isPressed = false

    init(_ title: String, iconName: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.action = action
    }

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
            .foregroundStyle(Color("AppPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppGradients.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.55), lineWidth: 1.5)
                    )
            }
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .depth(.raised, cornerRadius: 12)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}
