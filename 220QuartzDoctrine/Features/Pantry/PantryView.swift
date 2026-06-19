import SwiftUI

struct PantryView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var showAddSheet = false
    @State private var name = ""
    @State private var quantity = ""
    @State private var unit = "pcs"
    @State private var status = PantryStockStatus.inStock
    @State private var hasExpiry = false
    @State private var expiryDate = Date()
    @State private var nameError: String?
    @State private var shakeTrigger: CGFloat = 0
    @State private var addedCount = 0
    @State private var showAddedBanner = false

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    if !store.pantryItems.isEmpty {
                        PantryStatsRow(
                            inStock: store.pantryItems.filter { $0.status == .inStock }.count,
                            runningLow: store.pantryItems.filter { $0.status == .runningLow }.count,
                            outOfStock: store.pantryItems.filter { $0.status == .outOfStock }.count
                        )
                    }

                    if store.pantryItems.isEmpty {
                        EmptyStateView(
                            iconName: "archivebox.fill",
                            title: "Pantry is empty",
                            message: "Track what's in your pantry at home",
                            actionTitle: "Add First Item"
                        ) {
                            resetForm()
                            showAddSheet = true
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(store.pantryItems) { item in
                                    PantryItemCell(item: item) { newStatus in
                                        var updated = item
                                        updated.status = newStatus
                                        store.updatePantryItem(updated)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.deletePantryItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    if !store.pantryNeedsRestock.isEmpty {
                        SecondaryButton("Add Missing to Shopping List", iconName: "cart.badge.plus") {
                            FeedbackManager.mediumImpact()
                            addedCount = store.addMissingPantryToShoppingList()
                            if addedCount > 0 {
                                FeedbackManager.success()
                                withAnimation { showAddedBanner = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    withAnimation { showAddedBanner = false }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }

                    PrimaryButton(title: "Add Pantry Item", iconName: "plus") {
                        FeedbackManager.lightTap()
                        resetForm()
                        showAddSheet = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .overlay(alignment: .top) {
                    if showAddedBanner {
                        ToastBanner(message: "Added \(addedCount) items to shopping list")
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Pantry")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddSheet) { addSheet }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Item Name") {
                        TextField("e.g. Eggs", text: $name)
                            .modifier(ShakeEffect(animatableData: shakeTrigger))
                    }
                    if let nameError {
                        Text(nameError).font(.caption).foregroundStyle(Color("AppPrimary"))
                    }
                    HStack(spacing: 10) {
                        FormFieldCard(label: "Quantity") {
                            TextField("2", text: $quantity)
                        }
                        FormFieldCard(label: "Unit") {
                            TextField("pcs", text: $unit)
                        }
                    }
                    FormFieldCard(label: "Status") {
                        Picker("Status", selection: $status) {
                            ForEach(PantryStockStatus.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    SurfaceCard(elevation: .flat, inset: true) {
                        Toggle("Track expiry date", isOn: $hasExpiry)
                            .tint(Color("AppPrimary"))
                        if hasExpiry {
                            DatePicker("Expires", selection: $expiryDate, displayedComponents: .date)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Add Pantry Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveItem() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveItem() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            nameError = "Name is required"
            FeedbackManager.warning()
            withAnimation { shakeTrigger += 1 }
            return
        }
        store.addPantryItem(PantryItem(
            name: trimmed,
            quantity: quantity.isEmpty ? "1" : quantity,
            unit: unit,
            status: status,
            expiryDate: hasExpiry ? expiryDate : nil
        ))
        FeedbackManager.success()
        showAddSheet = false
    }

    private func resetForm() {
        name = ""
        quantity = ""
        unit = "pcs"
        status = .inStock
        hasExpiry = false
        expiryDate = Date()
        nameError = nil
    }
}
