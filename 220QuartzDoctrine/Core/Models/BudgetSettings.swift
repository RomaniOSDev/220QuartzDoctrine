import Foundation

struct BudgetSettings: Codable, Equatable {
    var weeklyLimit: Double
    var monthlyLimit: Double
    var categoryLimits: [String: Double]

    static let defaultCategories = ["Groceries", "Household", "Pharmacy", "Other"]

    init(
        weeklyLimit: Double = 150,
        monthlyLimit: Double = 600,
        categoryLimits: [String: Double] = [:]
    ) {
        self.weeklyLimit = weeklyLimit
        self.monthlyLimit = monthlyLimit
        self.categoryLimits = categoryLimits
    }

    func limit(for category: String) -> Double {
        categoryLimits[category] ?? 0
    }
}

struct BudgetSnapshot {
    let weeklySpent: Double
    let weeklyRemaining: Double
    let monthlySpent: Double
    let monthlyRemaining: Double
    let categorySpent: [String: Double]
}
