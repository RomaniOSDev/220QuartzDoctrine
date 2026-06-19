import SwiftUI

struct TemplateCell: View {
    let template: ListTemplate
    let onApply: () -> Void
    var isDue: Bool = false

    var body: some View {
        SurfaceCard(padding: 0, elevation: .flat) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    IconBadge(
                        iconName: template.isRecurring ? "arrow.triangle.2.circlepath" : "doc.on.doc.fill",
                        size: 46,
                        tint: isDue ? Color("AppPrimary") : Color("AppAccent")
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(template.name)
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            if isDue {
                                TagPill(text: "Due", tint: Color("AppPrimary"))
                            }
                        }
                        Text("\(template.items.count) items")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        if template.isRecurring {
                            Text("Every \(template.recurrenceIntervalDays) days")
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                    Spacer()
                }
                .padding(14)

                if !template.items.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(template.items.prefix(5)) { item in
                                TagPill(text: item.name)
                            }
                            if template.items.count > 5 {
                                TagPill(text: "+\(template.items.count - 5)", tint: Color("AppTextSecondary"))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                    }
                }

                Divider().background(Color("AppAccent").opacity(0.12))

                Button(action: onApply) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Apply to List")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

struct MealDayCell: View {
    let weekdayLabel: String
    let mealName: String?
    let mealTemplates: [MealTemplate]
    let onAssign: (MealTemplate) -> Void
    let onRemove: () -> Void

    @State private var showMealPicker = false

    var body: some View {
        SurfaceCard(padding: 12, elevation: .flat) {
            HStack(spacing: 14) {
                VStack(spacing: 2) {
                    Text(weekdayLabel)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
                .frame(width: 36)

                if let mealName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealName)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Scheduled")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)
                } else if mealTemplates.isEmpty {
                    Text("Create a meal template first")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                } else {
                    Button {
                        FeedbackManager.lightTap()
                        if mealTemplates.count == 1, let meal = mealTemplates.first {
                            onAssign(meal)
                        } else {
                            showMealPicker = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Assign meal")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color("AppPrimary"))
                    }
                    .buttonStyle(.plain)
                    .confirmationDialog(
                        "Assign Meal",
                        isPresented: $showMealPicker,
                        titleVisibility: .visible
                    ) {
                        ForEach(mealTemplates) { meal in
                            Button(meal.name) {
                                onAssign(meal)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Choose a meal for \(weekdayLabel)")
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct MealTemplateCell: View {
    let meal: MealTemplate

    var body: some View {
        SurfaceCard(elevation: .flat) {
            HStack(spacing: 14) {
                IconBadge(iconName: "fork.knife", size: 42, tint: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 6) {
                    Text(meal.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(meal.ingredients.count) ingredients")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if !meal.ingredients.isEmpty {
                        Text(meal.ingredients.prefix(3).map(\.name).joined(separator: " · "))
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct IngredientRowCell: View {
    let name: String
    let quantity: String

    var body: some View {
        HStack {
            IconBadge(iconName: "leaf.fill", size: 28, tint: Color("AppAccent"))
            Text(name)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            TagPill(text: quantity)
        }
        .padding(.vertical, 4)
    }
}

struct AchievementCell: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        SurfaceCard(padding: 12, elevation: .raised) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked
                                ? LinearGradient(
                                    colors: [Color("AppPrimary").opacity(0.4), Color("AppAccent").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color("AppSurface"), Color("AppBackground")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(width: 56, height: 56)
                    Image(systemName: achievement.iconName)
                        .font(.title2)
                        .foregroundStyle(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.35))
                }

                Text(achievement.title)
                    .font(.caption.bold())
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .opacity(isUnlocked ? 1 : 0.55)
        }
    }
}

struct SettingsRowCell: View {
    let title: String
    let iconName: String
    var isDestructive: Bool = false
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(
                iconName: iconName,
                size: 38,
                tint: isDestructive ? Color("AppPrimary") : Color("AppAccent")
            )
            Text(title)
                .font(.body)
                .foregroundStyle(isDestructive ? Color("AppPrimary") : Color("AppTextPrimary"))
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minHeight: 44)
    }
}

struct RecurringAlertCell: View {
    let templates: [ListTemplate]
    let onApply: (ListTemplate) -> Void

    var body: some View {
        SurfaceCard(elevation: .floating) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: "Recurring lists due",
                    subtitle: "Tap to add items to your list",
                    iconName: "bell.badge.fill"
                )
                ForEach(templates) { template in
                    HStack {
                        Text(template.name)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Spacer()
                        Button("Apply") {
                            onApply(template)
                        }
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("AppPrimary").opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
