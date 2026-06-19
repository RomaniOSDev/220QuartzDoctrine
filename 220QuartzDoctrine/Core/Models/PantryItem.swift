import Foundation

enum PantryStockStatus: String, Codable, CaseIterable {
    case inStock = "In Stock"
    case runningLow = "Running Low"
    case outOfStock = "Out of Stock"
}

struct PantryItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: String
    var unit: String
    var status: PantryStockStatus
    var expiryDate: Date?
    var lowStockThreshold: Double?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: String,
        unit: String = "pcs",
        status: PantryStockStatus = .inStock,
        expiryDate: Date? = nil,
        lowStockThreshold: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.status = status
        self.expiryDate = expiryDate
        self.lowStockThreshold = lowStockThreshold
    }

    var needsRestock: Bool {
        status == .runningLow || status == .outOfStock
    }
}
