import Foundation

struct PriceMemoryInfo: Identifiable, Equatable {
    var id: String { itemName.lowercased() }
    let itemName: String
    let minPrice: Double
    let averagePrice: Double
    let maxPrice: Double
    let lastPrice: Double
    let lastStore: String
    let lastDate: Date
    let purchaseCount: Int

    var formattedLastPaid: String {
        String(format: "Last paid $%.2f at %@", lastPrice, lastStore)
    }
}
