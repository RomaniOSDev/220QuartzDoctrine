import SwiftUI

struct TripModeView: View {
    @EnvironmentObject private var store: AppStorage

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                StoreChipBar(
                    stores: store.stores,
                    selectedId: store.selectedStoreId,
                    onSelect: {
                        FeedbackManager.lightTap()
                        store.selectStore($0)
                    },
                    onAdd: {}
                )

                if walkOrderItems.isEmpty {
                    EmptyStateView(
                        iconName: "map.fill",
                        title: "Ready for a store trip?",
                        message: "Add items to your list to walk through the store aisle by aisle"
                    )
                } else {
                    tripScroll
                    tripProgress
                }
            }
        }
    }

    private var walkOrderItems: [ShoppingItem] {
        store.aisleWalkOrderItems(for: store.defaultStoreId)
    }

    private var tripScroll: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                ForEach(store.itemsGroupedByAisle(for: store.defaultStoreId), id: \.aisle.id) { group in
                    Section {
                        ForEach(group.items) { item in
                            TripModeItemCell(item: item) {
                                FeedbackManager.mediumImpact()
                                FeedbackManager.playSystemSound(1003)
                                store.toggleShoppingItem(item)
                            }
                            .padding(.horizontal, 16)
                        }
                    } header: {
                        AisleGroupHeader(aisle: group.aisle, itemCount: group.items.count)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var tripProgress: some View {
        let items = walkOrderItems
        let done = items.filter(\.isChecked).count
        let total = max(items.count, 1)
        return SurfaceCard(elevation: .floating) {
            VStack(spacing: 10) {
                HStack {
                    SectionHeaderView(
                        title: "Trip Progress",
                        subtitle: "\(done) of \(items.count) collected",
                        iconName: "figure.walk"
                    )
                    Spacer()
                    Text("\(Int(Double(done) / Double(total) * 100))%")
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
                ProgressView(value: Double(done), total: Double(total))
                    .tint(Color("AppAccent"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
