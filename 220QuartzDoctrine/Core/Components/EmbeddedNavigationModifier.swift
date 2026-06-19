import SwiftUI

struct EmbeddedNavigationModifier: ViewModifier {
    let embedded: Bool
    let title: String
    var showSearch: Bool = false
    @Binding var showSearchBinding: Bool

    init(embedded: Bool, title: String, showSearch: Bool = false, showSearchBinding: Binding<Bool> = .constant(false)) {
        self.embedded = embedded
        self.title = title
        self.showSearch = showSearch
        self._showSearchBinding = showSearchBinding
    }

    func body(content: Content) -> some View {
        if embedded {
            content
        } else {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .appNavigationBarStyle()
                .toolbar {
                    if showSearch {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                FeedbackManager.lightTap()
                                showSearchBinding.toggle()
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                            .frame(minWidth: 44, minHeight: 44)
                        }
                    }
                }
        }
    }
}
