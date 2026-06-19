import SwiftUI

struct MealPlannerView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var showAddMealSheet = false
    @State private var mealName = ""
    @State private var ingredientName = ""
    @State private var ingredientQty = ""
    @State private var draftIngredients: [MealIngredient] = []

    private let weekdays = [(1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"), (5, "Thu"), (6, "Fri"), (7, "Sat")]

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 16) {
                        SectionHeaderView(
                            title: "This Week",
                            subtitle: "Plan meals and auto-build your list",
                            iconName: "calendar"
                        )
                        .padding(.horizontal, 16)

                        ForEach(weekdays, id: \.0) { day, label in
                            MealDayCell(
                                weekdayLabel: label,
                                mealName: scheduledMealName(for: day),
                                mealTemplates: store.mealTemplates,
                                onAssign: { meal in
                                    FeedbackManager.lightTap()
                                    store.scheduleMeal(mealTemplateId: meal.id, weekday: day)
                                },
                                onRemove: {
                                    if let s = store.scheduledMeals.first(where: { $0.weekday == day }) {
                                        store.removeScheduledMeal(s)
                                    }
                                }
                            )
                        }

                        SectionHeaderView(
                            title: "Meal Templates",
                            subtitle: "\(store.mealTemplates.count) saved",
                            iconName: "fork.knife",
                            trailing: "Add +"
                        )
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            FeedbackManager.lightTap()
                            resetMealForm()
                            showAddMealSheet = true
                        }

                        if store.mealTemplates.isEmpty {
                            EmptyStateView(
                                iconName: "fork.knife",
                                title: "No meals yet",
                                message: "Create meal templates with ingredients",
                                actionTitle: "Create Meal"
                            ) {
                                resetMealForm()
                                showAddMealSheet = true
                            }
                            .frame(height: 260)
                        } else {
                            ForEach(store.mealTemplates) { meal in
                                MealTemplateCell(meal: meal)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.deleteMealTemplate(meal)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }

                        combinedIngredientsCard

                        PrimaryButton(title: "Add Ingredients to Shopping List", iconName: "cart.badge.plus") {
                            FeedbackManager.mediumImpact()
                            let count = store.addMealIngredientsToShoppingList()
                            if count > 0 { FeedbackManager.success() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Meal Planner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackManager.lightTap()
                        resetMealForm()
                        showAddMealSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .sheet(isPresented: $showAddMealSheet) { addMealSheet }
        }
    }

    private var combinedIngredientsCard: some View {
        let ingredients = store.aggregatedMealIngredients()
        return SurfaceCard(elevation: .floating) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: "Combined Ingredients",
                    subtitle: ingredients.isEmpty ? "Schedule meals first" : "\(ingredients.count) items",
                    iconName: "list.bullet"
                )
                if !ingredients.isEmpty {
                    ForEach(ingredients, id: \.name) { item in
                        IngredientRowCell(name: item.name, quantity: item.quantity)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func scheduledMealName(for weekday: Int) -> String? {
        guard let scheduled = store.scheduledMeals.first(where: { $0.weekday == weekday }),
              let meal = store.meal(for: scheduled) else { return nil }
        return meal.name
    }

    private var addMealSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Meal Name") {
                        TextField("Pasta Night", text: $mealName)
                    }
                    FormFieldCard(label: "Ingredients") {
                        HStack {
                            TextField("Name", text: $ingredientName)
                            TextField("Qty", text: $ingredientQty)
                                .frame(width: 50)
                            Button {
                                let n = ingredientName.trimmingCharacters(in: .whitespaces)
                                guard !n.isEmpty else { return }
                                draftIngredients.append(MealIngredient(
                                    name: n,
                                    quantity: ingredientQty.isEmpty ? "1" : ingredientQty
                                ))
                                ingredientName = ""
                                ingredientQty = ""
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                        }
                    }
                    ForEach(draftIngredients) { ing in
                        SurfaceCard(padding: 10, elevation: .flat) {
                            IngredientRowCell(name: ing.name, quantity: ing.quantity)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddMealSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = mealName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else {
                            FeedbackManager.warning()
                            return
                        }
                        store.addMealTemplate(MealTemplate(name: trimmed, ingredients: draftIngredients))
                        FeedbackManager.success()
                        showAddMealSheet = false
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func resetMealForm() {
        mealName = ""
        ingredientName = ""
        ingredientQty = ""
        draftIngredients = []
    }
}
