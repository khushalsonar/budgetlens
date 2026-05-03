import SwiftUI

private struct SpendingBarDatum: Identifiable {
    let id: String
    let name: String
    let amount: Double
    let colorHex: String
}

struct SpendingChartView: View {
    private enum Scope: String, CaseIterable, Identifiable {
        case thisMonth = "This Month"
        case allTime = "All Time"

        var id: String { rawValue }
    }

    @State private var categories: [BudgetCategory] = []
    @State private var expenseTypes: [ExpenseType] = []
    @State private var scope: Scope = .thisMonth

    private let storage = StorageManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Range", selection: $scope) {
                    ForEach(Scope.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Text("Total spent: \(totalSpent.currencyINR)")
                    .font(.headline)

                if chartData.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.title2)
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("No expenses yet")
                            .font(.headline)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ChartBars(data: chartData)
                        .frame(height: 260)
                        .padding(.top, 8)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Spending by Type")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: reloadData)
    }

    private var filteredExpenses: [Expense] {
        let allExpenses = categories.flatMap(\.expenses)
        guard scope == .thisMonth else { return allExpenses }

        let month = StorageFormatting.monthString(from: Date())
        return allExpenses.filter { StorageFormatting.monthString(from: $0.date) == month }
    }

    private var totalSpent: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var chartData: [SpendingBarDatum] {
        let typeMap = Dictionary(uniqueKeysWithValues: expenseTypes.map { ($0.id, $0.name) })
        let grouped = Dictionary(grouping: filteredExpenses) { expense -> String in
            expense.expenseTypeID?.uuidString ?? "other"
        }

        return grouped.keys.sorted().enumerated().map { index, key in
            let amount = grouped[key, default: []].reduce(0) { $0 + $1.amount }
            let name: String
            if key == "other" {
                name = "Other"
            } else if let id = UUID(uuidString: key), let typeName = typeMap[id] {
                name = typeName
            } else {
                name = "Other"
            }

            let colorHex = CategoryColor.presets[index % CategoryColor.presets.count].hex
            return SpendingBarDatum(id: key, name: name, amount: amount, colorHex: colorHex)
        }
        .sorted { $0.amount > $1.amount }
    }

    private func reloadData() {
        categories = storage.loadCategories()
        expenseTypes = storage.loadExpenseTypes()
    }
}

private struct ChartBars: View {
    let data: [SpendingBarDatum]

    var body: some View {
        GeometryReader { geometry in
            let maxAmount = max(data.map(\.amount).max() ?? 1, 1)
            let barWidth = max((geometry.size.width - CGFloat((data.count - 1) * 12)) / CGFloat(max(data.count, 1)), 28)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(data) { item in
                    VStack(spacing: 6) {
                        Text(item.amount.currencyINR)
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: item.colorHex))
                            .frame(height: max(12, (item.amount / maxAmount) * 150))

                        Text(item.name)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: barWidth)
                    }
                    .frame(width: barWidth)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}
