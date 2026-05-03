import Foundation

struct BudgetCategory: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var budget: Double
    var expenses: [Expense]
    var colorHex: String
    var currentMonth: String
    var carriedOver: Double
    var allowCarryover: Bool

    var totalSpent: Double { expenses.reduce(0) { $0 + $1.amount } }
    var effectiveBudget: Double { budget + carriedOver }
    var remaining: Double { effectiveBudget - totalSpent }

    var progress: Double {
        guard effectiveBudget > 0 else { return 0 }
        return min(totalSpent / effectiveBudget, 1.0)
    }

    init(
        id: UUID = UUID(),
        name: String,
        budget: Double,
        expenses: [Expense] = [],
        colorHex: String,
        currentMonth: String = StorageFormatting.monthString(from: Date()),
        carriedOver: Double = 0,
        allowCarryover: Bool = true
    ) {
        self.id = id
        self.name = name
        self.budget = budget
        self.expenses = expenses
        self.colorHex = colorHex
        self.currentMonth = currentMonth
        self.carriedOver = carriedOver
        self.allowCarryover = allowCarryover
    }
}
