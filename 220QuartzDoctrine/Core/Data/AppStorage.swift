import Combine
import Foundation

final class AppStorage: ObservableObject {
    static let shared = AppStorage()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let itemsCreated = "itemsCreated"
        static let shoppingItems = "shoppingItems"
        static let purchaseHistory = "purchaseHistory"
        static let currentFilter = "currentFilter"
        static let stores = "stores"
        static let selectedStoreId = "selectedStoreId"
        static let pantryItems = "pantryItems"
        static let budgetSettings = "budgetSettings"
        static let listTemplates = "listTemplates"
        static let mealTemplates = "mealTemplates"
        static let scheduledMeals = "scheduledMeals"
        static let tripModeEnabled = "tripModeEnabled"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }
    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }
    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }
    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }
    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }
    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveJSON(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }
    @Published var itemsCreated: Int {
        didSet { defaults.set(itemsCreated, forKey: Keys.itemsCreated) }
    }
    @Published var shoppingItems: [ShoppingItem] {
        didSet { saveJSON(shoppingItems, key: Keys.shoppingItems) }
    }
    @Published var purchaseHistory: [Purchase] {
        didSet { saveJSON(purchaseHistory, key: Keys.purchaseHistory) }
    }
    @Published var currentFilter: String {
        didSet { defaults.set(currentFilter, forKey: Keys.currentFilter) }
    }
    @Published var stores: [StoreProfile] {
        didSet { saveJSON(stores, key: Keys.stores) }
    }
    @Published var selectedStoreId: UUID? {
        didSet {
            if let id = selectedStoreId {
                defaults.set(id.uuidString, forKey: Keys.selectedStoreId)
            } else {
                defaults.removeObject(forKey: Keys.selectedStoreId)
            }
        }
    }
    @Published var pantryItems: [PantryItem] {
        didSet { saveJSON(pantryItems, key: Keys.pantryItems) }
    }
    @Published var budgetSettings: BudgetSettings {
        didSet { saveJSON(budgetSettings, key: Keys.budgetSettings) }
    }
    @Published var listTemplates: [ListTemplate] {
        didSet { saveJSON(listTemplates, key: Keys.listTemplates) }
    }
    @Published var mealTemplates: [MealTemplate] {
        didSet { saveJSON(mealTemplates, key: Keys.mealTemplates) }
    }
    @Published var scheduledMeals: [ScheduledMeal] {
        didSet { saveJSON(scheduledMeals, key: Keys.scheduledMeals) }
    }
    @Published var tripModeEnabled: Bool {
        didSet { defaults.set(tripModeEnabled, forKey: Keys.tripModeEnabled) }
    }
    @Published var pendingAchievementBanner: Achievement?
    @Published var budgetWarningMessage: String?

    private var achievementQueue: [Achievement] = []
    private let defaults = UserDefaults.standard
    private var sessionStartDate: Date?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadMap(from: defaults, key: Keys.achievementsUnlocked)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        shoppingItems = Self.loadArray(from: defaults, key: Keys.shoppingItems)
        purchaseHistory = Self.loadArray(from: defaults, key: Keys.purchaseHistory)
        currentFilter = defaults.string(forKey: Keys.currentFilter) ?? "weekly"
        stores = Self.loadArray(from: defaults, key: Keys.stores)
        pantryItems = Self.loadArray(from: defaults, key: Keys.pantryItems)
        budgetSettings = Self.loadObject(from: defaults, key: Keys.budgetSettings) ?? BudgetSettings()
        listTemplates = Self.loadArray(from: defaults, key: Keys.listTemplates)
        mealTemplates = Self.loadArray(from: defaults, key: Keys.mealTemplates)
        scheduledMeals = Self.loadArray(from: defaults, key: Keys.scheduledMeals)
        tripModeEnabled = defaults.bool(forKey: Keys.tripModeEnabled)
        if let idString = defaults.string(forKey: Keys.selectedStoreId),
           let id = UUID(uuidString: idString) {
            selectedStoreId = id
        } else {
            selectedStoreId = nil
        }
        sessionStartDate = Date()
        migrateIfNeeded()
        seedDefaultsIfEmpty()

        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
            .store(in: &cancellables)
    }

    // MARK: - Migration & Seeds

    private func migrateIfNeeded() {
        if stores.isEmpty {
            let general = StoreProfile(name: "General", sortOrder: 0)
            stores = [general]
            selectedStoreId = general.id
            shoppingItems = shoppingItems.map { item in
                var copy = item
                copy.storeId = general.id
                return copy
            }
        }
        if selectedStoreId == nil {
            selectedStoreId = stores.first?.id
        }
        let validStoreIds = Set(stores.map(\.id))
        shoppingItems = shoppingItems.map { item in
            var copy = item
            if !validStoreIds.contains(copy.storeId) {
                copy.storeId = defaultStoreId
            }
            return copy
        }
    }

    private func seedDefaultsIfEmpty() {
        if listTemplates.isEmpty {
            let storeId = selectedStoreId ?? stores.first?.id
            listTemplates = [
                ListTemplate(
                    name: "Weekly Essentials",
                    items: [
                        TemplateItem(name: "Milk", quantity: "2", aisleCategory: AisleCategory.dairy.rawValue),
                        TemplateItem(name: "Eggs", quantity: "12", aisleCategory: AisleCategory.dairy.rawValue),
                        TemplateItem(name: "Bread", quantity: "1", aisleCategory: AisleCategory.bakery.rawValue),
                        TemplateItem(name: "Chicken", quantity: "1 kg", aisleCategory: AisleCategory.meat.rawValue),
                        TemplateItem(name: "Rice", quantity: "1", aisleCategory: AisleCategory.other.rawValue),
                        TemplateItem(name: "Apples", quantity: "6", aisleCategory: AisleCategory.produce.rawValue),
                        TemplateItem(name: "Tomatoes", quantity: "4", aisleCategory: AisleCategory.produce.rawValue),
                        TemplateItem(name: "Cheese", quantity: "1", aisleCategory: AisleCategory.dairy.rawValue),
                        TemplateItem(name: "Butter", quantity: "1", aisleCategory: AisleCategory.dairy.rawValue),
                        TemplateItem(name: "Orange Juice", quantity: "1", aisleCategory: AisleCategory.beverages.rawValue),
                        TemplateItem(name: "Pasta", quantity: "2", aisleCategory: AisleCategory.other.rawValue),
                        TemplateItem(name: "Coffee", quantity: "1", aisleCategory: AisleCategory.beverages.rawValue),
                        TemplateItem(name: "Yogurt", quantity: "4", aisleCategory: AisleCategory.dairy.rawValue),
                        TemplateItem(name: "Bananas", quantity: "5", aisleCategory: AisleCategory.produce.rawValue),
                        TemplateItem(name: "Paper Towels", quantity: "1", aisleCategory: AisleCategory.household.rawValue)
                    ],
                    isRecurring: true,
                    recurrenceIntervalDays: 7,
                    targetStoreId: storeId
                )
            ]
        }
    }

    var defaultStoreId: UUID {
        selectedStoreId ?? stores.first?.id ?? UUID()
    }

    // MARK: - Onboarding & Session

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordMeaningfulAction()
    }

    func endSession() {
        guard let start = sessionStartDate else { return }
        let minutes = max(1, Int(Date().timeIntervalSince(start) / 60))
        totalMinutesUsed += minutes
        totalSessionsCompleted += 1
        sessionStartDate = Date()
        checkAchievements()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        migrateIfNeeded()
        seedDefaultsIfEmpty()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    // MARK: - Stores

    func addStore(name: String) {
        let store = StoreProfile(name: name, sortOrder: stores.count)
        stores.append(store)
        recordMeaningfulAction()
    }

    func deleteStore(_ store: StoreProfile) {
        guard stores.count > 1 else { return }
        stores.removeAll { $0.id == store.id }
        shoppingItems.removeAll { $0.storeId == store.id }
        if selectedStoreId == store.id {
            selectedStoreId = stores.first?.id
        }
    }

    func selectStore(_ store: StoreProfile) {
        selectedStoreId = store.id
    }

    func items(for storeId: UUID) -> [ShoppingItem] {
        shoppingItems.filter { $0.storeId == storeId }
    }

    func itemsGroupedByAisle(for storeId: UUID) -> [(aisle: AisleCategory, items: [ShoppingItem])] {
        let items = items(for: storeId)
        let grouped = Dictionary(grouping: items) { item in
            AisleCategory(rawValue: item.aisleCategory) ?? .other
        }
        return AisleCategory.allCases.compactMap { aisle in
            guard let aisleItems = grouped[aisle], !aisleItems.isEmpty else { return nil }
            let sorted = aisleItems.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            return (aisle, sorted)
        }
    }

    func aisleWalkOrderItems(for storeId: UUID) -> [ShoppingItem] {
        itemsGroupedByAisle(for: storeId).flatMap(\.items)
    }

    // MARK: - Shopping List

    func addShoppingItem(
        name: String,
        quantity: String,
        storeId: UUID? = nil,
        aisleCategory: String = AisleCategory.other.rawValue,
        estimatedPrice: Double? = nil
    ) {
        let store = storeId ?? defaultStoreId
        let price = estimatedPrice ?? PriceMemoryCalculator.memory(for: name, purchases: purchaseHistory)?.lastPrice
        let item = ShoppingItem(
            name: name,
            quantity: quantity,
            storeId: store,
            aisleCategory: aisleCategory,
            estimatedPrice: price
        )
        shoppingItems.append(item)
        itemsCreated += 1
        recordMeaningfulAction()
        checkAchievements()
    }

    func toggleShoppingItem(_ item: ShoppingItem) {
        guard let index = shoppingItems.firstIndex(where: { $0.id == item.id }) else { return }
        shoppingItems[index].isChecked.toggle()
        recordMeaningfulAction()
    }

    func deleteShoppingItem(_ item: ShoppingItem) {
        shoppingItems.removeAll { $0.id == item.id }
    }

    var uncheckedItemCount: Int {
        shoppingItems.filter { !$0.isChecked }.count
    }

    // MARK: - Pantry

    func addPantryItem(_ item: PantryItem) {
        pantryItems.append(item)
        recordMeaningfulAction()
    }

    func updatePantryItem(_ item: PantryItem) {
        guard let index = pantryItems.firstIndex(where: { $0.id == item.id }) else { return }
        pantryItems[index] = item
        recordMeaningfulAction()
    }

    func deletePantryItem(_ item: PantryItem) {
        pantryItems.removeAll { $0.id == item.id }
    }

    var pantryNeedsRestock: [PantryItem] {
        pantryItems.filter(\.needsRestock)
    }

    func addMissingPantryToShoppingList(storeId: UUID? = nil) -> Int {
        let missing = pantryNeedsRestock
        let store = storeId ?? defaultStoreId
        var added = 0
        for pantryItem in missing {
            let alreadyListed = shoppingItems.contains {
                $0.storeId == store &&
                $0.name.lowercased() == pantryItem.name.lowercased() &&
                !$0.isChecked
            }
            guard !alreadyListed else { continue }
            addShoppingItem(name: pantryItem.name, quantity: "1", storeId: store)
            added += 1
        }
        return added
    }

    // MARK: - Purchases

    @discardableResult
    func addPurchase(_ purchase: Purchase) -> String? {
        let warning = budgetWarning(for: purchase.totalSpent, category: purchase.budgetCategory)
        purchaseHistory.insert(purchase, at: 0)
        budgetWarningMessage = warning
        recordMeaningfulAction()
        checkAchievements()
        return warning
    }

    func markPurchaseReviewed(_ purchase: Purchase) {
        guard let index = purchaseHistory.firstIndex(where: { $0.id == purchase.id }) else { return }
        purchaseHistory[index].reviewed = true
        recordMeaningfulAction()
    }

    func deletePurchase(_ purchase: Purchase) {
        purchaseHistory.removeAll { $0.id == purchase.id }
    }

    // MARK: - Budget

    func updateBudgetSettings(_ settings: BudgetSettings) {
        budgetSettings = settings
        recordMeaningfulAction()
    }

    func budgetSnapshot() -> BudgetSnapshot {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        let weeklySpent = purchaseHistory
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.totalSpent }

        let monthlySpent = purchaseHistory
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.totalSpent }

        var categorySpent: [String: Double] = [:]
        for purchase in purchaseHistory where calendar.isDate(purchase.date, equalTo: now, toGranularity: .month) {
            categorySpent[purchase.budgetCategory, default: 0] += purchase.totalSpent
        }

        return BudgetSnapshot(
            weeklySpent: weeklySpent,
            weeklyRemaining: max(0, budgetSettings.weeklyLimit - weeklySpent),
            monthlySpent: monthlySpent,
            monthlyRemaining: max(0, budgetSettings.monthlyLimit - monthlySpent),
            categorySpent: categorySpent
        )
    }

    func budgetWarning(for amount: Double, category: String) -> String? {
        let snapshot = budgetSnapshot()
        if snapshot.weeklySpent + amount > budgetSettings.weeklyLimit {
            return "This purchase exceeds your weekly budget of \(formattedCurrency(budgetSettings.weeklyLimit))."
        }
        if snapshot.monthlySpent + amount > budgetSettings.monthlyLimit {
            return "This purchase exceeds your monthly budget of \(formattedCurrency(budgetSettings.monthlyLimit))."
        }
        let catLimit = budgetSettings.limit(for: category)
        if catLimit > 0 {
            let spent = snapshot.categorySpent[category] ?? 0
            if spent + amount > catLimit {
                return "This exceeds your \(category) limit of \(formattedCurrency(catLimit))."
            }
        }
        return nil
    }

    // MARK: - Templates

    func addTemplate(_ template: ListTemplate) {
        listTemplates.append(template)
        recordMeaningfulAction()
    }

    func updateTemplate(_ template: ListTemplate) {
        guard let index = listTemplates.firstIndex(where: { $0.id == template.id }) else { return }
        listTemplates[index] = template
    }

    func deleteTemplate(_ template: ListTemplate) {
        listTemplates.removeAll { $0.id == template.id }
    }

    @discardableResult
    func applyTemplate(_ template: ListTemplate, to storeId: UUID? = nil) -> Int {
        let store = template.targetStoreId ?? storeId ?? defaultStoreId
        var added = 0
        for templateItem in template.items {
            let exists = shoppingItems.contains {
                $0.storeId == store &&
                $0.name.lowercased() == templateItem.name.lowercased() &&
                !$0.isChecked
            }
            guard !exists else { continue }
            addShoppingItem(
                name: templateItem.name,
                quantity: templateItem.quantity,
                storeId: store,
                aisleCategory: templateItem.aisleCategory
            )
            added += 1
        }
        if let index = listTemplates.firstIndex(where: { $0.id == template.id }) {
            listTemplates[index].lastAppliedDate = Date()
        }
        return added
    }

    var dueRecurringTemplates: [ListTemplate] {
        listTemplates.filter(\.isDueForRecurrence)
    }

    // MARK: - Meals

    func addMealTemplate(_ meal: MealTemplate) {
        mealTemplates.append(meal)
        recordMeaningfulAction()
    }

    func updateMealTemplate(_ meal: MealTemplate) {
        guard let index = mealTemplates.firstIndex(where: { $0.id == meal.id }) else { return }
        mealTemplates[index] = meal
    }

    func deleteMealTemplate(_ meal: MealTemplate) {
        mealTemplates.removeAll { $0.id == meal.id }
        scheduledMeals.removeAll { $0.mealTemplateId == meal.id }
    }

    func scheduleMeal(mealTemplateId: UUID, weekday: Int) {
        var updated = scheduledMeals
        updated.removeAll { $0.weekday == weekday }
        updated.append(ScheduledMeal(mealTemplateId: mealTemplateId, weekday: weekday))
        scheduledMeals = updated
        recordMeaningfulAction()
    }

    func removeScheduledMeal(_ scheduled: ScheduledMeal) {
        scheduledMeals = scheduledMeals.filter { $0.id != scheduled.id }
    }

    func meal(for scheduled: ScheduledMeal) -> MealTemplate? {
        mealTemplates.first { $0.id == scheduled.mealTemplateId }
    }

    func aggregatedMealIngredients(storeId: UUID? = nil) -> [(name: String, quantity: String)] {
        var merged: [String: String] = [:]
        for scheduled in scheduledMeals {
            guard let meal = meal(for: scheduled) else { continue }
            for ingredient in meal.ingredients {
                let key = ingredient.name.lowercased()
                if merged[key] == nil {
                    merged[key] = ingredient.quantity
                }
            }
        }
        return merged.map { ($0.key.capitalized, $0.value) }.sorted { $0.name < $1.name }
    }

    @discardableResult
    func addMealIngredientsToShoppingList(storeId: UUID? = nil) -> Int {
        let store = storeId ?? defaultStoreId
        var added = 0
        for ingredient in aggregatedMealIngredients() {
            let exists = shoppingItems.contains {
                $0.storeId == store &&
                $0.name.lowercased() == ingredient.name.lowercased() &&
                !$0.isChecked
            }
            guard !exists else { continue }
            addShoppingItem(name: ingredient.name, quantity: ingredient.quantity, storeId: store)
            added += 1
        }
        return added
    }

    // MARK: - Price Memory

    var priceMemories: [PriceMemoryInfo] {
        PriceMemoryCalculator.allMemories(from: purchaseHistory)
    }

    func priceHint(for itemName: String) -> String? {
        guard let memory = PriceMemoryCalculator.memory(for: itemName, purchases: purchaseHistory) else {
            return nil
        }
        return memory.formattedLastPaid
    }

    var frequentItemSuggestions: [String] {
        PriceMemoryCalculator.suggestions(from: purchaseHistory)
    }

    // MARK: - Analytics

    var totalSpend: Double {
        purchaseHistory.reduce(0) { $0 + $1.totalSpent }
    }

    var monthlyAverage: Double {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: purchaseHistory) {
            calendar.dateComponents([.year, .month], from: $0.date)
        }
        guard !grouped.isEmpty else { return 0 }
        let totals = grouped.values.map { $0.reduce(0) { $0 + $1.totalSpent } }
        return totals.reduce(0, +) / Double(totals.count)
    }

    var itemsPurchasedCount: Int {
        purchaseHistory.reduce(0) { total, purchase in
            let count = purchase.lineItems.isEmpty
                ? purchase.items.split(separator: ",").filter { !$0.isEmpty }.count
                : purchase.lineItems.count
            return total + max(count, 1)
        }
    }

    func monthlySpendData(forYear year: Int? = nil) -> [(month: Int, amount: Double)] {
        let calendar = Calendar.current
        let targetYear = year ?? calendar.component(.year, from: Date())
        return (1...12).map { month in
            let amount = purchaseHistory.filter {
                calendar.component(.year, from: $0.date) == targetYear &&
                calendar.component(.month, from: $0.date) == month
            }.reduce(0) { $0 + $1.totalSpent }
            return (month: month, amount: amount)
        }
    }

    func filteredPurchases(filter: String, searchText: String) -> [Purchase] {
        let calendar = Calendar.current
        let now = Date()
        let filtered: [Purchase]
        switch filter {
        case "monthly":
            filtered = purchaseHistory.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case "yearly":
            filtered = purchaseHistory.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
        default:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            filtered = purchaseHistory.filter { $0.date >= weekAgo }
        }
        guard !searchText.isEmpty else { return filtered }
        return filtered.filter {
            $0.storeName.localizedCaseInsensitiveContains(searchText) ||
            $0.items.localizedCaseInsensitiveContains(searchText)
        }
    }

    func recordMeaningfulAction() {
        updateStreak()
        checkAchievements()
    }

    func dismissAchievementBanner() {
        pendingAchievementBanner = nil
        if !achievementQueue.isEmpty {
            let next = achievementQueue.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.pendingAchievementBanner = next
                FeedbackManager.success()
            }
        }
    }

    func formattedCurrency(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }

    // MARK: - Private

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(lastDay, inSameDayAs: today) { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    private func checkAchievements() {
        for achievement in Achievement.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            guard achievement.isUnlocked(self) else { continue }
            achievementsUnlocked[achievement.id] = Date()
            enqueueAchievementBanner(achievement)
        }
    }

    private func enqueueAchievementBanner(_ achievement: Achievement) {
        if pendingAchievementBanner == nil {
            pendingAchievementBanner = achievement
            FeedbackManager.success()
        } else {
            achievementQueue.append(achievement)
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadMap(from: defaults, key: Keys.achievementsUnlocked)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        shoppingItems = Self.loadArray(from: defaults, key: Keys.shoppingItems)
        purchaseHistory = Self.loadArray(from: defaults, key: Keys.purchaseHistory)
        currentFilter = defaults.string(forKey: Keys.currentFilter) ?? "weekly"
        stores = Self.loadArray(from: defaults, key: Keys.stores)
        pantryItems = Self.loadArray(from: defaults, key: Keys.pantryItems)
        budgetSettings = Self.loadObject(from: defaults, key: Keys.budgetSettings) ?? BudgetSettings()
        listTemplates = Self.loadArray(from: defaults, key: Keys.listTemplates)
        mealTemplates = Self.loadArray(from: defaults, key: Keys.mealTemplates)
        scheduledMeals = Self.loadArray(from: defaults, key: Keys.scheduledMeals)
        tripModeEnabled = defaults.bool(forKey: Keys.tripModeEnabled)
        if let idString = defaults.string(forKey: Keys.selectedStoreId),
           let id = UUID(uuidString: idString) {
            selectedStoreId = id
        } else {
            selectedStoreId = nil
        }
        pendingAchievementBanner = nil
        achievementQueue = []
        budgetWarningMessage = nil
        sessionStartDate = Date()
        migrateIfNeeded()
    }

    private func saveJSON<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadArray<T: Decodable>(from defaults: UserDefaults, key: String) -> [T] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([T].self, from: data) else { return [] }
        return decoded
    }

    private static func loadObject<T: Decodable>(from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        return decoded
    }

    private static func loadMap(from defaults: UserDefaults, key: String) -> [String: Date] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else { return [:] }
        return decoded
    }
}
