import SwiftUI

struct PriceMemoryView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var searchText = ""

    private var filtered: [PriceMemoryInfo] {
        guard !searchText.isEmpty else { return store.priceMemories }
        return store.priceMemories.filter {
            $0.itemName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if store.priceMemories.isEmpty {
                EmptyStateView(
                    iconName: "dollarsign.circle.fill",
                    title: "No price history",
                    message: "Log purchases to build your personal price memory"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered) { memory in
                            PriceMemoryCell(memory: memory)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .searchable(text: $searchText, prompt: "Search items")
            }
        }
    }
}
