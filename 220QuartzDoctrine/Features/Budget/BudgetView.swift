import SwiftUI

struct BudgetView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var weeklyLimitText = ""
    @State private var monthlyLimitText = ""
    @State private var categoryLimits: [String: String] = [:]
    @State private var showEditSheet = false

    private var snapshot: BudgetSnapshot { store.budgetSnapshot() }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                BudgetOverviewCell(
                    title: "Weekly Budget",
                    spent: snapshot.weeklySpent,
                    limit: store.budgetSettings.weeklyLimit,
                    remaining: snapshot.weeklyRemaining
                )
                BudgetOverviewCell(
                    title: "Monthly Budget",
                    spent: snapshot.monthlySpent,
                    limit: store.budgetSettings.monthlyLimit,
                    remaining: snapshot.monthlyRemaining
                )

                SectionHeaderView(
                    title: "Category Limits",
                    subtitle: "Track spending by type",
                    iconName: "chart.pie.fill"
                )
                .padding(.horizontal, 16)
                .padding(.top, 4)

                ForEach(BudgetSettings.defaultCategories, id: \.self) { category in
                    CategoryBudgetCell(
                        category: category,
                        spent: snapshot.categorySpent[category] ?? 0,
                        limit: store.budgetSettings.limit(for: category)
                    )
                }

                SecondaryButton("Edit Budget Limits", iconName: "slider.horizontal.3") {
                    loadEditFields()
                    showEditSheet = true
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .padding(.top, 8)
        }
        .onAppear { loadEditFields() }
        .sheet(isPresented: $showEditSheet) { editSheet }
    }

    private var editSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Weekly Limit ($)") {
                        TextField("150", text: $weeklyLimitText).keyboardType(.decimalPad)
                    }
                    FormFieldCard(label: "Monthly Limit ($)") {
                        TextField("600", text: $monthlyLimitText).keyboardType(.decimalPad)
                    }
                    ForEach(BudgetSettings.defaultCategories, id: \.self) { category in
                        FormFieldCard(label: "\(category) Limit ($)") {
                            TextField("Optional", text: binding(for: category))
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showEditSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveBudget() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func binding(for category: String) -> Binding<String> {
        Binding(get: { categoryLimits[category] ?? "" }, set: { categoryLimits[category] = $0 })
    }

    private func loadEditFields() {
        weeklyLimitText = String(format: "%.0f", store.budgetSettings.weeklyLimit)
        monthlyLimitText = String(format: "%.0f", store.budgetSettings.monthlyLimit)
        for cat in BudgetSettings.defaultCategories {
            let limit = store.budgetSettings.limit(for: cat)
            categoryLimits[cat] = limit > 0 ? String(format: "%.0f", limit) : ""
        }
    }

    private func saveBudget() {
        var settings = store.budgetSettings
        settings.weeklyLimit = Double(weeklyLimitText) ?? settings.weeklyLimit
        settings.monthlyLimit = Double(monthlyLimitText) ?? settings.monthlyLimit
        var limits: [String: Double] = [:]
        for (key, value) in categoryLimits {
            if let amount = Double(value), amount > 0 { limits[key] = amount }
        }
        settings.categoryLimits = limits
        store.updateBudgetSettings(settings)
        FeedbackManager.success()
        showEditSheet = false
    }
}
