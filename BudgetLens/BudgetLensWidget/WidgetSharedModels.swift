import Foundation
import SwiftUI

struct Expense: Codable, Identifiable, Equatable {
    var id: UUID
    var amount: Double
    var note: String
    var date: Date
    var expenseTypeID: UUID?

    init(id: UUID = UUID(), amount: Double, note: String, date: Date = Date(), expenseTypeID: UUID? = nil) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
        self.expenseTypeID = expenseTypeID
    }
}

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
        currentMonth: String = WidgetFormatting.monthString(from: Date()),
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

private enum WidgetFormatting {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    static func monthString(from date: Date) -> String {
        monthFormatter.string(from: date)
    }
}

extension Double {
    var currencyINR: String {
        WidgetFormatting.currencyFormatter.string(from: NSNumber(value: self)) ?? "₹0"
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

struct ProgressBarView: View {
    let progress: Double
    let fillColor: Color
    let height: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))

                Capsule()
                    .fill(fillColor)
                    .frame(width: geometry.size.width * max(0, min(progress, 1)))
            }
        }
        .frame(height: height)
        .clipShape(Capsule())
    }
}
