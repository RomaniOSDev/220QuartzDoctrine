import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary"))
                    .frame(width: 56, height: 56)
                Image(systemName: "checkmark")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}
