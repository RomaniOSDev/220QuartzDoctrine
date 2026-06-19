import Foundation

struct TemplateItem: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var quantity: String
    var aisleCategory: String

    init(id: UUID = UUID(), name: String, quantity: String, aisleCategory: String = AisleCategory.other.rawValue) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.aisleCategory = aisleCategory
    }
}

struct ListTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var items: [TemplateItem]
    var isRecurring: Bool
    var recurrenceIntervalDays: Int
    var lastAppliedDate: Date?
    var targetStoreId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        items: [TemplateItem] = [],
        isRecurring: Bool = false,
        recurrenceIntervalDays: Int = 7,
        lastAppliedDate: Date? = nil,
        targetStoreId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.isRecurring = isRecurring
        self.recurrenceIntervalDays = recurrenceIntervalDays
        self.lastAppliedDate = lastAppliedDate
        self.targetStoreId = targetStoreId
    }

    var isDueForRecurrence: Bool {
        guard isRecurring else { return false }
        guard let last = lastAppliedDate else { return true }
        let due = Calendar.current.date(byAdding: .day, value: recurrenceIntervalDays, to: last) ?? last
        return Date() >= due
    }
}
