import SwiftUI

struct ShopContainerView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var section = 0

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    StyledSegmentedPicker(selection: $section, labels: ["Lists", "Templates", "Trip"])

                    switch section {
                    case 0:
                        ShoppingListView(embedded: true)
                    case 1:
                        TemplatesView()
                    default:
                        TripModeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(sectionTitle)
            .navigationBarTitleDisplayMode(.large)
            .appNavigationBarStyle()
        }
    }

    private var sectionTitle: String {
        switch section {
        case 0: return "Shopping List"
        case 1: return "Templates"
        default: return "Store Trip"
        }
    }
}
