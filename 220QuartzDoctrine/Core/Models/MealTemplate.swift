import Foundation

struct MealIngredient: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var quantity: String

    init(id: UUID = UUID(), name: String, quantity: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}

struct MealTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ingredients: [MealIngredient]

    init(id: UUID = UUID(), name: String, ingredients: [MealIngredient] = []) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
    }
}

struct ScheduledMeal: Identifiable, Codable, Equatable {
    let id: UUID
    var mealTemplateId: UUID
    var weekday: Int

    init(id: UUID = UUID(), mealTemplateId: UUID, weekday: Int) {
        self.id = id
        self.mealTemplateId = mealTemplateId
        self.weekday = weekday
    }
}
