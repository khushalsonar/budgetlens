import Foundation
import Combine
import WidgetKit

final class StorageManager: ObservableObject {
    static let shared = StorageManager()

    static let appGroupID = "group.com.personal.budgetlens"
    private let categoriesKey = "budget_categories"
    private let widgetSelectionKey = "widget_selected_category_id"
    private let expenseTypesKey = "expenseTypes"

    @Published private(set) var dataVersion = UUID()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        defaults = UserDefaults(suiteName: Self.appGroupID) ?? .standard
        seedDefaultExpenseTypesIfNeeded()
    }

    func reload() {
        dataVersion = UUID()
    }

    func loadCategories() -> [BudgetCategory] {
        guard let data = defaults.data(forKey: categoriesKey),
              let categories = try? decoder.decode([BudgetCategory].self, from: data) else {
            return []
        }
        return categories
    }

    func saveCategories(_ categories: [BudgetCategory]) {
        var unique: [BudgetCategory] = []
        var seen = Set<UUID>()
        for category in categories {
            guard !seen.contains(category.id) else { continue }
            seen.insert(category.id)
            unique.append(category)
        }

        guard let data = try? encoder.encode(unique) else { return }
        defaults.set(data, forKey: categoriesKey)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func addCategory(_ category: BudgetCategory) {
        var categories = loadCategories()
        guard !categories.contains(where: { $0.id == category.id }) else { return }
        categories.append(category)
        saveCategories(categories)
    }

    func updateCategory(_ category: BudgetCategory) {
        var categories = loadCategories()
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
        saveCategories(categories)
    }

    func deleteCategory(_ categoryID: UUID) {
        var categories = loadCategories()
        categories.removeAll { $0.id == categoryID }
        saveCategories(categories)

        if widgetSelectedCategoryID == categoryID {
            widgetSelectedCategoryID = nil
        }
    }

    @discardableResult
    func addExpense(to categoryID: UUID, expense: Expense) -> Bool {
        var categories = loadCategories()
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else { return false }
        categories[index].expenses.insert(expense, at: 0)
        saveCategories(categories)
        return true
    }

    @discardableResult
    func updateExpense(
        expenseID: UUID,
        in categoryID: UUID,
        amount: Double,
        note: String,
        expenseTypeID: UUID?
    ) -> Bool {
        var categories = loadCategories()
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }),
              let expenseIndex = categories[categoryIndex].expenses.firstIndex(where: { $0.id == expenseID }) else {
            return false
        }

        categories[categoryIndex].expenses[expenseIndex].amount = amount
        categories[categoryIndex].expenses[expenseIndex].note = note
        categories[categoryIndex].expenses[expenseIndex].expenseTypeID = expenseTypeID
        saveCategories(categories)
        return true
    }

    func deleteExpense(categoryID: UUID, expenseID: UUID) {
        var categories = loadCategories()
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[categoryIndex].expenses.removeAll { $0.id == expenseID }
        saveCategories(categories)
    }

    @discardableResult
    func performMonthlyResetIfNeeded() -> Bool {
        let month = StorageFormatting.monthString(from: Date())
        var categories = loadCategories()
        var hasChanges = false

        for index in categories.indices {
            guard categories[index].currentMonth != month else { continue }
            let leftover = categories[index].budget - categories[index].totalSpent
            let carried = categories[index].allowCarryover ? max(leftover, 0) : 0

            categories[index].expenses = []
            categories[index].carriedOver = carried
            categories[index].currentMonth = month
            hasChanges = true
        }

        if hasChanges {
            saveCategories(categories)
            WidgetCenter.shared.reloadAllTimelines()
        }

        return hasChanges
    }

    func loadExpenseTypes() -> [ExpenseType] {
        guard let data = defaults.data(forKey: expenseTypesKey),
              let types = try? decoder.decode([ExpenseType].self, from: data) else {
            return []
        }
        return types
    }

    func saveExpenseTypes(_ types: [ExpenseType]) {
        guard let data = try? encoder.encode(types) else { return }
        defaults.set(data, forKey: expenseTypesKey)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func addExpenseType(_ type: ExpenseType) {
        var types = loadExpenseTypes()
        guard !types.contains(where: { $0.id == type.id }) else { return }
        types.append(type)
        saveExpenseTypes(types)
    }

    func deleteExpenseType(_ id: UUID) {
        var types = loadExpenseTypes()
        guard types.count > 1 else { return }
        types.removeAll { $0.id == id }
        saveExpenseTypes(types)
    }

    var widgetSelectedCategoryID: UUID? {
        get {
            guard let idString = defaults.string(forKey: widgetSelectionKey) else { return nil }
            return UUID(uuidString: idString)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: widgetSelectionKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func seedDefaultExpenseTypesIfNeeded() {
        guard loadExpenseTypes().isEmpty else { return }

        let defaults = [
            ExpenseType(name: "Food"),
            ExpenseType(name: "Travel"),
            ExpenseType(name: "Shopping")
        ]

        saveExpenseTypes(defaults)
    }
}
