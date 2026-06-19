import Foundation

enum AisleCategory: String, Codable, CaseIterable, Identifiable {
    case produce = "Produce"
    case dairy = "Dairy"
    case meat = "Meat"
    case bakery = "Bakery"
    case frozen = "Frozen"
    case beverages = "Beverages"
    case household = "Household"
    case pharmacy = "Pharmacy"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .produce: return "leaf.fill"
        case .dairy: return "drop.fill"
        case .meat: return "fork.knife"
        case .bakery: return "birthday.cake.fill"
        case .frozen: return "snowflake"
        case .beverages: return "cup.and.saucer.fill"
        case .household: return "house.fill"
        case .pharmacy: return "cross.case.fill"
        case .other: return "bag.fill"
        }
    }

    var storeWalkOrder: Int {
        switch self {
        case .produce: return 0
        case .bakery: return 1
        case .meat: return 2
        case .dairy: return 3
        case .frozen: return 4
        case .beverages: return 5
        case .household: return 6
        case .pharmacy: return 7
        case .other: return 8
        }
    }
}
