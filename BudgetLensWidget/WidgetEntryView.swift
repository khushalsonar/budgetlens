import SwiftUI
import WidgetKit

struct BudgetLensWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: BudgetLensWidgetEntry

    var body: some View {
        if let category = entry.category {
            switch family {
            case .systemMedium:
                mediumWidget(category: category)
            default:
                smallWidget(category: category)
            }
        } else {
            placeholderView
        }
    }

    private func smallWidget(category: BudgetCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            header(category: category)

            Text(category.remaining.currencyINR)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            ProgressBarView(progress: category.progress, fillColor: Color(hex: category.colorHex), height: 6)

            Text("\(category.totalSpent.currencyINR) of \(category.effectiveBudget.currencyINR)")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func mediumWidget(category: BudgetCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                header(category: category)
                Spacer()
                Text("\(Int((category.progress * 100).rounded()))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.35))
            }

            Text(category.remaining.currencyINR)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            ProgressBarView(progress: category.progress, fillColor: Color(hex: category.colorHex), height: 6)

            if !category.expenses.isEmpty {
                Text("Recent")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.35))
                    .textCase(.uppercase)

                VStack(spacing: 8) {
                    let recentExpenses = Array(category.expenses.sorted(by: { $0.date > $1.date }).prefix(2))
                    ForEach(Array(recentExpenses.enumerated()), id: \.1.id) { index, expense in
                        VStack(spacing: 4) {
                            HStack {
                                Text(expense.amount.currencyINR)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.85))
                                Spacer()
                                Text(expense.note.isEmpty ? "Expense" : expense.note)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.white.opacity(0.45))
                                    .lineLimit(1)
                                    .multilineTextAlignment(.trailing)
                            }

                            if index < recentExpenses.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 1)
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func header(category: BudgetCategory) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Circle()
                .fill(Color(hex: category.colorHex))
                .frame(width: 9, height: 9)

            Text(category.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
                .lineLimit(1)
        }
    }

    private var placeholderView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No category selected")
                .font(.headline)
                .foregroundColor(Color.white.opacity(0.7))
            Text("Open BudgetLens to create categories.")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.5))
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
