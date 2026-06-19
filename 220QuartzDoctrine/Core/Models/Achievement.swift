import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: (AppStorage) -> Bool

    static let all: [Achievement] = [
        Achievement(
            id: "first_item",
            title: "First Item",
            description: "Created your first shopping item",
            iconName: "bag.fill",
            isUnlocked: { $0.itemsCreated >= 1 }
        ),
        Achievement(
            id: "list_maker",
            title: "List Maker",
            description: "Created five different shopping lists",
            iconName: "list.bullet.rectangle.fill",
            isUnlocked: { $0.itemsCreated >= 5 }
        ),
        Achievement(
            id: "shopping_enthusiast",
            title: "Shopping Enthusiast",
            description: "Completed ten sessions using the app",
            iconName: "cart.fill",
            isUnlocked: { $0.totalSessionsCompleted >= 10 }
        ),
        Achievement(
            id: "routine_shopper",
            title: "Routine Shopper",
            description: "Used the app daily for a week",
            iconName: "calendar",
            isUnlocked: { $0.streakDays >= 7 }
        ),
        Achievement(
            id: "saver",
            title: "$ Saver",
            description: "Saved money by optimizing purchases over fifty sessions",
            iconName: "dollarsign.circle.fill",
            isUnlocked: { $0.totalSessionsCompleted >= 50 }
        ),
        Achievement(
            id: "organizational_guru",
            title: "Organizational Guru",
            description: "Created twenty-five lists",
            iconName: "folder.fill",
            isUnlocked: { $0.itemsCreated >= 25 }
        ),
        Achievement(
            id: "dedicated_user",
            title: "Dedicated User",
            description: "Consistently used the app for thirty days straight",
            iconName: "star.fill",
            isUnlocked: { $0.streakDays >= 30 }
        ),
        Achievement(
            id: "getting_going",
            title: "Getting Going",
            description: "Reached 10 items.",
            iconName: "arrow.up.circle.fill",
            isUnlocked: { $0.itemsCreated >= 10 }
        )
    ]
}
