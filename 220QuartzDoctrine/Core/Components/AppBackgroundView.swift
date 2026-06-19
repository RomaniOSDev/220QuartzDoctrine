import SwiftUI

struct AppBackgroundView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppGradients.screenBackground
                .ignoresSafeArea()

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.14), Color.clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 280
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color("AppAccent").opacity(0.07), Color.clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 240
            )
            .ignoresSafeArea()

            content
        }
        .preferredColorScheme(.dark)
    }
}
