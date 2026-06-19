import Foundation

struct PurchaseLineItem: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var price: Double
    var category: String

    init(id: UUID = UUID(), name: String, price: Double, category: String = "Groceries") {
        self.id = id
        self.name = name
        self.price = price
        self.category = category
    }
}

struct Purchase: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var storeName: String
    var items: String
    var totalSpent: Double
    var reviewed: Bool
    var lineItems: [PurchaseLineItem]
    var budgetCategory: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        storeName: String,
        items: String,
        totalSpent: Double,
        reviewed: Bool = false,
        lineItems: [PurchaseLineItem] = [],
        budgetCategory: String = "Groceries"
    ) {
        self.id = id
        self.date = date
        self.storeName = storeName
        self.items = items
        self.totalSpent = totalSpent
        self.reviewed = reviewed
        self.lineItems = lineItems
        self.budgetCategory = budgetCategory
    }

    enum CodingKeys: String, CodingKey {
        case id, date, storeName, items, totalSpent, reviewed, lineItems, budgetCategory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        storeName = try container.decode(String.self, forKey: .storeName)
        items = try container.decode(String.self, forKey: .items)
        totalSpent = try container.decode(Double.self, forKey: .totalSpent)
        reviewed = try container.decode(Bool.self, forKey: .reviewed)
        lineItems = try container.decodeIfPresent([PurchaseLineItem].self, forKey: .lineItems) ?? []
        budgetCategory = try container.decodeIfPresent(String.self, forKey: .budgetCategory) ?? "Groceries"
    }
}
