import SwiftUI

struct TrackContainerView: View {
    @State private var selectedSection = 0
    @State private var showHistorySearch = false

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    StyledSegmentedPicker(
                        selection: $selectedSection,
                        labels: ["History", "Insights", "Budget", "Prices"]
                    )

                    Group {
                        switch selectedSection {
                        case 0:
                            PurchaseHistoryView(embeddedInTrack: true, searchPresented: $showHistorySearch)
                        case 1:
                            SpendingInsightsView(embeddedInTrack: true)
                        case 2:
                            BudgetView()
                        default:
                            PriceMemoryView()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(sectionTitle)
            .navigationBarTitleDisplayMode(.large)
            .appNavigationBarStyle()
            .toolbar {
                if selectedSection == 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            FeedbackManager.lightTap()
                            showHistorySearch.toggle()
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

    private var sectionTitle: String {
        switch selectedSection {
        case 0: return "Purchase History"
        case 1: return "Spending Insights"
        case 2: return "Budget"
        default: return "Price Memory"
        }
    }
}
