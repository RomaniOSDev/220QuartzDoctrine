import SwiftUI

struct ShoppingListView: View {
    var embedded = false
    @StateObject private var viewModel = ShoppingListViewModel()
    @EnvironmentObject private var store: AppStorage

    var body: some View {
        Group {
            if embedded { content } else { NavigationStack { content } }
        }
    }

    private var content: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                StoreChipBar(
                    stores: viewModel.stores,
                    selectedId: store.selectedStoreId,
                    onSelect: { viewModel.selectStore($0) },
                    onAdd: {
                        FeedbackManager.lightTap()
                        viewModel.showAddStoreSheet = true
                    }
                )

                if viewModel.isEmpty {
                    EmptyStateView(
                        iconName: "cart.fill.badge.plus",
                        title: "Your list is empty",
                        message: "Add items to start building your shopping list",
                        actionTitle: "Add First Item"
                    ) {
                        viewModel.openAddSheet()
                    }
                } else {
                    aisleScrollList
                }

                if !viewModel.isEmpty {
                    SummaryBannerCell(
                        leadingTitle: "Items Needed",
                        leadingValue: "\(viewModel.uncheckedCount)",
                        trailingText: "\(store.items(for: viewModel.selectedStoreId).count) total"
                    )
                }

                PrimaryButton(title: "Add Item", iconName: "plus") {
                    viewModel.openAddSheet()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay {
                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay)
            }
        }
        .modifier(EmbeddedNavigationModifier(embedded: embedded, title: "Shopping List", showSearch: false))
        .toolbar {
            if !embedded {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackManager.lightTap()
                        viewModel.showAddStoreSheet = true
                    } label: {
                        Image(systemName: "building.2.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) { addItemSheet }
        .sheet(isPresented: $viewModel.showAddStoreSheet) { addStoreSheet }
    }

    private var aisleScrollList: some View {
        ScrollView {
            LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.groupedItems, id: \.aisle.id) { group in
                    Section {
                        ForEach(group.items) { item in
                            ShoppingItemCell(
                                item: item,
                                priceHint: store.priceHint(for: item.name)
                            ) {
                                viewModel.toggleItem(item)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        AisleGroupHeader(aisle: group.aisle, itemCount: group.items.count)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 12)
        }
    }

    private var addItemSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Item Name") {
                        TextField("e.g. Milk", text: $viewModel.itemName)
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                            .onChange(of: viewModel.itemName) { _ in viewModel.updatePriceHint() }
                    }
                    if let error = viewModel.nameError {
                        Text(error).font(.caption).foregroundStyle(Color("AppPrimary"))
                    }
                    if let hint = viewModel.priceHint {
                        SurfaceCard(padding: 12, elevation: .floating) {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(Color("AppAccent"))
                                Text(hint)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppAccent"))
                            }
                        }
                    }
                    FormFieldCard(label: "Quantity") {
                        TextField("1", text: $viewModel.itemQuantity)
                    }
                    FormFieldCard(label: "Aisle") {
                        Picker("Aisle", selection: $viewModel.selectedAisle) {
                            ForEach(AisleCategory.allCases) { aisle in
                                Text(aisle.rawValue).tag(aisle.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    if !viewModel.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Add")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextSecondary"))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                                        FilterChip(title: suggestion, isSelected: false) {
                                            viewModel.itemName = suggestion
                                            viewModel.updatePriceHint()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        viewModel.showAddSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.saveItem() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var addStoreSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FormFieldCard(label: "Store Name") {
                    TextField("e.g. Local Market", text: $viewModel.newStoreName)
                        .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                }
                if let error = viewModel.storeError {
                    Text(error).font(.caption).foregroundStyle(Color("AppPrimary"))
                }
                Spacer()
            }
            .padding(16)
            .background(Color("AppBackground"))
            .navigationTitle("Add Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        viewModel.showAddStoreSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.saveStore() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
    }
}
