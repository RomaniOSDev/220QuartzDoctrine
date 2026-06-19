import SwiftUI

struct PurchaseHistoryView: View {
    var embeddedInTrack = false
    var searchPresented: Binding<Bool>?
    @StateObject private var viewModel = PurchaseHistoryViewModel()
    @EnvironmentObject private var store: AppStorage

    private var searchBinding: Binding<Bool> {
        searchPresented ?? $viewModel.showSearch
    }

    var body: some View {
        Group {
            if embeddedInTrack { content } else { NavigationStack { content } }
        }
    }

    private var content: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                filterChips

                if viewModel.isEmpty {
                    EmptyStateView(
                        iconName: "doc.text.magnifyingglass",
                        title: "No purchases yet",
                        message: "No Purchase History Yet – Start Shopping!",
                        actionTitle: "Add Purchase"
                    ) {
                        viewModel.openAddSheet()
                    }
                } else if viewModel.filteredPurchases.isEmpty {
                    EmptyStateView(
                        iconName: "magnifyingglass",
                        title: "No matches",
                        message: "No purchases match your current filter"
                    )
                } else {
                    purchaseScroll
                }

                PrimaryButton(title: "Add Purchase", iconName: "plus") {
                    viewModel.openAddSheet()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .modifier(EmbeddedNavigationModifier(
            embedded: embeddedInTrack,
            title: "Purchase History",
            showSearch: true,
            showSearchBinding: searchBinding
        ))
        .sheet(isPresented: $viewModel.showAddSheet) { addPurchaseSheet }
        .searchable(text: $viewModel.searchText, isPresented: searchBinding)
        .alert("Budget Warning", isPresented: $viewModel.showBudgetWarning) {
            Button("OK") { FeedbackManager.lightTap() }
        } message: {
            Text(viewModel.budgetWarning ?? "This purchase exceeds your budget.")
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([("weekly", "Weekly"), ("monthly", "Monthly"), ("yearly", "Yearly")], id: \.0) { key, label in
                    FilterChip(title: label, isSelected: store.currentFilter == key) {
                        viewModel.setFilter(key)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var purchaseScroll: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredPurchases) { purchase in
                    if !viewModel.removingPurchaseIDs.contains(purchase.id) {
                        PurchaseCardWrapper(purchase: purchase)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .contextMenu {
                                if !purchase.reviewed {
                                    Button {
                                        viewModel.markReviewed(purchase)
                                    } label: {
                                        Label("Mark Reviewed", systemImage: "checkmark.seal")
                                    }
                                }
                                Button(role: .destructive) {
                                    viewModel.deletePurchase(purchase)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.removingPurchaseIDs)
    }

    private var addPurchaseSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Date") {
                        DatePicker("", selection: $viewModel.purchaseDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    FormFieldCard(label: "Store Name") {
                        TextField("Store", text: $viewModel.storeName)
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                    }
                    if let error = viewModel.storeError {
                        Text(error).font(.caption).foregroundStyle(Color("AppPrimary"))
                    }
                    FormFieldCard(label: "Items") {
                        TextField("Milk, Eggs, Bread", text: $viewModel.itemsText)
                    }
                    FormFieldCard(label: "Total Spent ($)") {
                        TextField("0.00", text: $viewModel.totalSpentText)
                            .keyboardType(.decimalPad)
                    }
                    if let error = viewModel.amountError {
                        Text(error).font(.caption).foregroundStyle(Color("AppPrimary"))
                    }
                    FormFieldCard(label: "Budget Category") {
                        Picker("Category", selection: $viewModel.budgetCategory) {
                            ForEach(BudgetSettings.defaultCategories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Add Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        viewModel.showAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.savePurchase() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct PurchaseCardWrapper: View {
    let purchase: Purchase
    @State private var isExpanded = false

    var body: some View {
        PurchaseCardCell(purchase: purchase, isExpanded: $isExpanded)
    }
}
