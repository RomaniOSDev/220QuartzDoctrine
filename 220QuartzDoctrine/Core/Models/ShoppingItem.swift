import Foundation

struct ShoppingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: String
    var isChecked: Bool
    var storeId: UUID
    var aisleCategory: String
    var estimatedPrice: Double?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: String,
        isChecked: Bool = false,
        storeId: UUID,
        aisleCategory: String = AisleCategory.other.rawValue,
        estimatedPrice: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.storeId = storeId
        self.aisleCategory = aisleCategory
        self.estimatedPrice = estimatedPrice
    }

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, isChecked, storeId, aisleCategory, estimatedPrice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(String.self, forKey: .quantity)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
        storeId = try container.decodeIfPresent(UUID.self, forKey: .storeId) ?? UUID()
        aisleCategory = try container.decodeIfPresent(String.self, forKey: .aisleCategory) ?? AisleCategory.other.rawValue
        estimatedPrice = try container.decodeIfPresent(Double.self, forKey: .estimatedPrice)
    }
}
