import Combine
import Foundation
import SwiftUI

final class ShoppingListViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showAddStoreSheet = false
    @Published var showSuccessOverlay = false
    @Published var itemName = ""
    @Published var itemQuantity = ""
    @Published var selectedAisle = AisleCategory.other.rawValue
    @Published var newStoreName = ""
    @Published var nameError: String?
    @Published var storeError: String?
    @Published var shakeTrigger: CGFloat = 0
    @Published var priceHint: String?

    private let store: AppStorage

    init(store: AppStorage = .shared) {
        self.store = store
    }

    var selectedStoreId: UUID {
        store.defaultStoreId
    }

    var stores: [StoreProfile] {
        store.stores
    }

    var groupedItems: [(aisle: AisleCategory, items: [ShoppingItem])] {
        store.itemsGroupedByAisle(for: selectedStoreId)
    }

    var isEmpty: Bool {
        store.items(for: selectedStoreId).isEmpty
    }

    var uncheckedCount: Int {
        store.items(for: selectedStoreId).filter { !$0.isChecked }.count
    }

    var suggestions: [String] {
        store.frequentItemSuggestions
    }

    func selectStore(_ storeProfile: StoreProfile) {
        FeedbackManager.lightTap()
        store.selectStore(storeProfile)
    }

    func updatePriceHint() {
        priceHint = store.priceHint(for: itemName)
    }

    func toggleItem(_ item: ShoppingItem) {
        FeedbackManager.lightTap()
        FeedbackManager.playSystemSound(1003)
        store.toggleShoppingItem(item)
    }

    func deleteItem(_ item: ShoppingItem) {
        FeedbackManager.lightTap()
        store.deleteShoppingItem(item)
    }

    func saveItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            nameError = "Item name is required"
            FeedbackManager.warning()
            withAnimation { shakeTrigger += 1 }
            return
        }
        let quantity = itemQuantity.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalQuantity = quantity.isEmpty ? "1" : quantity
        store.addShoppingItem(
            name: trimmedName,
            quantity: finalQuantity,
            storeId: selectedStoreId,
            aisleCategory: selectedAisle
        )
        FeedbackManager.mediumImpact()
        FeedbackManager.playSystemSound(1103)
        FeedbackManager.success()
        resetForm()
        showAddSheet = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessOverlay = true
        }
    }

    func saveStore() {
        let trimmed = newStoreName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            storeError = "Store name is required"
            FeedbackManager.warning()
            withAnimation { shakeTrigger += 1 }
            return
        }
        store.addStore(name: trimmed)
        FeedbackManager.success()
        newStoreName = ""
        storeError = nil
        showAddStoreSheet = false
    }

    func openAddSheet() {
        FeedbackManager.lightTap()
        resetForm()
        showAddSheet = true
    }

    private func resetForm() {
        itemName = ""
        itemQuantity = ""
        selectedAisle = AisleCategory.other.rawValue
        nameError = nil
        priceHint = nil
    }
}
