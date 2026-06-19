import Combine
import Foundation
import SwiftUI

final class SpendingInsightsViewModel: ObservableObject {
    @Published var chartTimeframe: ChartTimeframe = .monthly
    @Published var showAddSheet = false
    @Published var chartGrowthScale: CGFloat = 1.0
    @Published var storeName = ""
    @Published var itemsText = ""
    @Published var totalSpentText = ""
    @Published var purchaseDate = Date()
    @Published var storeError: String?
    @Published var amountError: String?
    @Published var shakeTrigger: CGFloat = 0

    enum ChartTimeframe: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }

    private let store: AppStorage

    init(store: AppStorage = .shared) {
        self.store = store
    }

    var isEmpty: Bool {
        store.purchaseHistory.isEmpty
    }

    var totalSpend: Double {
        store.totalSpend
    }

    var monthlyAverage: Double {
        store.monthlyAverage
    }

    var itemsPurchased: Int {
        store.itemsPurchasedCount
    }

    var chartData: [(label: String, amount: Double)] {
        switch chartTimeframe {
        case .weekly:
            return weeklyChartData()
        case .monthly:
            return store.monthlySpendData().map { item in
                (monthAbbreviation(item.month), item.amount)
            }
        case .yearly:
            return yearlyChartData()
        }
    }

    var maxChartValue: Double {
        max(chartData.map(\.amount).max() ?? 1, 1)
    }

    func selectTimeframe(_ timeframe: ChartTimeframe) {
        FeedbackManager.lightTap()
        chartTimeframe = timeframe
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
            if hasError {
                FeedbackManager.warning()
                withAnimation { shakeTrigger += 1 }
            }
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
            lineItems = [PurchaseLineItem(name: finalItems, price: amount, category: "Groceries")]
        } else {
            let share = amount / Double(itemNames.count)
            lineItems = itemNames.map { PurchaseLineItem(name: $0, price: share, category: "Groceries") }
        }

        let purchase = Purchase(
            date: purchaseDate,
            storeName: trimmedStore,
            items: finalItems,
            totalSpent: amount,
            lineItems: lineItems,
            budgetCategory: "Groceries"
        )
        store.addPurchase(purchase)
        FeedbackManager.mediumImpact()
        FeedbackManager.playSystemSound(1102)
        FeedbackManager.success()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            chartGrowthScale = 1.08
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self?.chartGrowthScale = 1.0
            }
        }

        showAddSheet = false
        resetForm()
    }

    private func resetForm() {
        storeName = ""
        itemsText = ""
        totalSpentText = ""
        purchaseDate = Date()
        storeError = nil
        amountError = nil
    }

    private func weeklyChartData() -> [(label: String, amount: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [(label: String, amount: Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        for offset in (0..<7).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let amount = store.purchaseHistory
                .filter { $0.date >= day && $0.date < nextDay }
                .reduce(0) { $0 + $1.totalSpent }
            result.append((formatter.string(from: day), amount))
        }
        return result
    }

    private func yearlyChartData() -> [(label: String, amount: Double)] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return (0..<5).reversed().map { offset in
            let year = currentYear - offset
            let amount = store.purchaseHistory
                .filter { calendar.component(.year, from: $0.date) == year }
                .reduce(0) { $0 + $1.totalSpent }
            return (String(year), amount)
        }
    }

    private func monthAbbreviation(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var components = DateComponents()
        components.month = month
        components.day = 1
        components.year = Calendar.current.component(.year, from: Date())
        guard let date = Calendar.current.date(from: components) else { return "M\(month)" }
        return formatter.string(from: date)
    }
}
