import Combine
import Foundation
import SwiftUI

final class PurchaseHistoryViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showSearch = false
    @Published var searchText = ""
    @Published var storeName = ""
    @Published var itemsText = ""
    @Published var totalSpentText = ""
    @Published var purchaseDate = Date()
    @Published var storeError: String?
    @Published var amountError: String?
    @Published var shakeTrigger: CGFloat = 0
    @Published var budgetCategory = "Groceries"
    @Published var budgetWarning: String?
    @Published var showBudgetWarning = false
    @Published var removingPurchaseIDs: Set<UUID> = []

    private let store: AppStorage

    init(store: AppStorage = .shared) {
        self.store = store
    }

    var currentFilter: String {
        get { store.currentFilter }
        set { store.currentFilter = newValue }
    }

    var filteredPurchases: [Purchase] {
        store.filteredPurchases(filter: store.currentFilter, searchText: searchText)
    }

    var isEmpty: Bool {
        store.purchaseHistory.isEmpty
    }

    func setFilter(_ filter: String) {
        FeedbackManager.lightTap()
        store.currentFilter = filter
    }

    func markReviewed(_ purchase: Purchase) {
        FeedbackManager.mediumImpact()
        FeedbackManager.playSystemSound(1104)
        withAnimation(.easeInOut(duration: 0.3)) {
            removingPurchaseIDs.insert(purchase.id)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.store.markPurchaseReviewed(purchase)
            self?.removingPurchaseIDs.remove(purchase.id)
        }
    }

    func deletePurchase(_ purchase: Purchase) {
        FeedbackManager.lightTap()
        store.deletePurchase(purchase)
    }

    func openAddSheet() {
        FeedbackManager.lightTap()
        resetForm()
        showAddSheet = true
    }

    func savePurchase() {
        let trimmedStore = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
        var hasError = false

        if trimmedStore.isEmpty {
            storeError = "Store name is required"
            hasError = true
        } else {
            storeError = nil
        }

        guard let amount = Double(totalSpentText.trimmingCharacters(in: .whitespacesAndNewlines)), amount > 0 else {
            amountError = "Enter a valid amount"
            hasError = true
            FeedbackManager.warning()
            withAnimation { shakeTrigger += 1 }
            return
        }
        amountError = nil

        if hasError {
            FeedbackManager.warning()
            withAnimation { shakeTrigger += 1 }
            return
        }

        let items = itemsText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalItems = items.isEmpty ? "General purchase" : items

        let itemNames = finalItems
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let lineItems: [PurchaseLineItem]
        if itemNames.isEmpty {
            lineItems = [PurchaseLineItem(name: finalItems, price: amount, category: budgetCategory)]
        } else {
            let share = amount / Double(itemNames.count)
            lineItems = itemNames.map { PurchaseLineItem(name: $0, price: share, category: budgetCategory) }
        }

        let purchase = Purchase(
            date: purchaseDate,
            storeName: trimmedStore,
            items: finalItems,
            totalSpent: amount,
            lineItems: lineItems,
            budgetCategory: budgetCategory
        )
        if let warning = store.addPurchase(purchase) {
            budgetWarning = warning
            showBudgetWarning = true
        }
        FeedbackManager.mediumImpact()
        FeedbackManager.playSystemSound(1104)
        FeedbackManager.success()

        showAddSheet = false
        resetForm()
    }

    private func resetForm() {
        storeName = ""
        itemsText = ""
        totalSpentText = ""
        purchaseDate = Date()
        budgetCategory = "Groceries"
        storeError = nil
        amountError = nil
        budgetWarning = nil
    }
}
