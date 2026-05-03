import SwiftUI
import WidgetKit

struct CategoryDetailView: View {
    let categoryID: UUID

    @ObservedObject private var storage = StorageManager.shared

    @State private var category: BudgetCategory?
    @State private var expenseTypes: [ExpenseType] = []
    @State private var showAddExpense = false
    @State private var showEditCategory = false
    @State private var expenseToEdit: Expense?
    @State private var showYearOverview = false
    @State private var widgetSelectedCategoryID: UUID? = nil

    var body: some View {
        Group {
            if let category {
                List {
                    Section {
                        heroCard(for: category)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

//                        Spacer(minLength: 16)

                        Button {
                            showAddExpense = true
                        } label: {
                            Text("Add Expense")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(hex: category.colorHex), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(Color(.systemBackground))
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

//                        Spacer(minLength: 10)

                        Button {
                            widgetSelectedCategoryID = category.id
                            storage.widgetSelectedCategoryID = category.id
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Image(systemName: (widgetSelectedCategoryID ?? storage.widgetSelectedCategoryID) == category.id ? "checkmark.circle.fill" : "square")
                                Text((widgetSelectedCategoryID ?? storage.widgetSelectedCategoryID) == category.id ? "Shown in Widget" : "Show in Widget")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listRowSeparator(.hidden)

                    if category.expenses.isEmpty {
                        Section {
                            VStack(spacing: 8) {
                                Image(systemName: "creditcard")
                                    .font(.title2)
                                    .foregroundStyle(Color(.secondaryLabel))
                                Text("No expenses yet")
                                    .font(.headline)
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        let typeNames = Dictionary(uniqueKeysWithValues: expenseTypes.map { ($0.id, $0.name) })

                        ForEach(groupedExpenses(category.expenses), id: \.0) { section in
                            Section(header: Text(section.0)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))) {
                                ForEach(section.1) { expense in
                                    ExpenseRow(expense: expense, expenseTypeName: expense.expenseTypeID.flatMap { typeNames[$0] })
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                storage.deleteExpense(categoryID: category.id, expenseID: expense.id)
                                                WidgetCenter.shared.reloadAllTimelines()
                                                reloadData()
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }

                                            Button {
                                                expenseToEdit = expense
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.orange)
                                        }
                                }
                            }
                        }
                    }

                    Section {
                        yearlyOverview(for: category)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .navigationTitle(category.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit") {
                            showEditCategory = true
                        }
                    }
                }
                .sheet(isPresented: $showAddExpense) {
                    AddExpenseSheet(category: category, expenseTypes: expenseTypes) { expense in
                        _ = storage.addExpense(to: category.id, expense: expense)
                        WidgetCenter.shared.reloadAllTimelines()
                        reloadData()
                    }
                }
                .sheet(isPresented: $showEditCategory) {
                    AddCategorySheet(
                        existingCategory: category,
                        existingCategoryNames: storage.loadCategories()
                            .filter { $0.id != category.id }
                            .map(\.name)
                    ) { updated in
                        storage.updateCategory(updated)
                        WidgetCenter.shared.reloadAllTimelines()
                        reloadData()
                    }
                }
                .sheet(item: $expenseToEdit) { expense in
                    EditExpenseSheet(category: category, expense: expense, expenseTypes: expenseTypes) { amount, note, expenseTypeID in
                        _ = storage.updateExpense(
                            expenseID: expense.id,
                            in: category.id,
                            amount: amount,
                            note: note,
                            expenseTypeID: expenseTypeID
                        )
                        WidgetCenter.shared.reloadAllTimelines()
                        reloadData()
                    }
                }
            } else {
                Text("Category not found")
                    .foregroundStyle(Color(.secondaryLabel))
                    .onAppear(perform: reloadData)
            }
        }
        .onAppear {
            reloadData()
            widgetSelectedCategoryID = storage.widgetSelectedCategoryID
        }
        .onReceive(storage.$dataVersion) { _ in
            reloadData()
            widgetSelectedCategoryID = storage.widgetSelectedCategoryID
        }
    }

    @ViewBuilder
    private func heroCard(for category: BudgetCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 12, height: 12)
                Text(category.name)
                    .font(.headline)
                Spacer()
            }

            Text(StorageFormatting.displayMonthYear(from: category.currentMonth))
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))

            Text("\(category.remaining.currencyINR) left")
                .font(.system(size: 32, weight: .semibold))

            Text("of \(category.effectiveBudget.currencyINR) budget")
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))

            ProgressBarView(
                progress: category.progress,
                fillColor: progressColor(for: category.progress),
                height: 12
            )

            Text("\(category.totalSpent.currencyINR) spent")
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))

            if category.carriedOver > 0,
               let previousMonthName = StorageFormatting.previousMonthName(from: category.currentMonth) {
                Text("\(category.carriedOver.currencyINR) carried over from \(previousMonthName)")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color(.label).opacity(0.05), radius: 4, x: 0, y: 1)
    }

    @ViewBuilder
    private func expensesSection(for category: BudgetCategory) -> some View {
        if category.expenses.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "creditcard")
                    .font(.title2)
                    .foregroundStyle(Color(.secondaryLabel))
                Text("No expenses yet")
                    .font(.headline)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            let typeNames = Dictionary(uniqueKeysWithValues: expenseTypes.map { ($0.id, $0.name) })

            VStack(alignment: .leading, spacing: 12) {
                ForEach(groupedExpenses(category.expenses), id: \.0) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.0)
                            .font(.subheadline)
                            .foregroundStyle(Color(.secondaryLabel))

                        ForEach(section.1) { expense in
                            ExpenseRow(expense: expense, expenseTypeName: expense.expenseTypeID.flatMap { typeNames[$0] })
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        storage.deleteExpense(categoryID: category.id, expenseID: expense.id)
                                        WidgetCenter.shared.reloadAllTimelines()
                                        reloadData()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        expenseToEdit = expense
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func yearlyOverview(for category: BudgetCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showYearOverview.toggle()
                }
            } label: {
                HStack {
                    Text("This Year's Overview")
                        .font(.headline)
                    Spacer()
                    Image(systemName: showYearOverview ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .buttonStyle(.plain)

            if showYearOverview {
                YearlyLineGraphView(
                    spentValues: yearlySpentData(for: category),
                    budgetValues: Array(repeating: category.budget, count: 12),
                    spentColor: Color(hex: category.colorHex)
                )
                .frame(height: 160)

                HStack(spacing: 16) {
                    legendDot(color: Color(hex: category.colorHex), title: "Spent")
                    legendDot(color: Color(.systemGray), title: "Budget")
                }
                .font(.caption)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
        )
    }

    private func legendDot(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
        }
    }

    private func yearlySpentData(for category: BudgetCategory) -> [Double] {
        let year = Calendar.current.component(.year, from: Date())
        var values = Array(repeating: 0.0, count: 12)

        for expense in category.expenses {
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            guard expenseYear == year else { continue }
            let monthIndex = Calendar.current.component(.month, from: expense.date) - 1
            values[monthIndex] += expense.amount
        }

        return values
    }

    private func groupedExpenses(_ expenses: [Expense]) -> [(String, [Expense])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses.sorted(by: { $0.date > $1.date })) { expense -> Date in
            calendar.startOfDay(for: expense.date)
        }

        let sortedDates = grouped.keys.sorted(by: >)
        return sortedDates.map { date in
            let title: String
            if calendar.isDateInToday(date) {
                title = "Today"
            } else if calendar.isDateInYesterday(date) {
                title = "Yesterday"
            } else {
                title = date.formatted(date: .abbreviated, time: .omitted)
            }
            return (title, grouped[date] ?? [])
        }
    }

    private func progressColor(for progress: Double) -> Color {
        switch progress {
        case ..<0.7:
            return .green
        case ..<0.9:
            return .orange
        default:
            return .red
        }
    }

    private func reloadData() {
        category = storage.loadCategories().first(where: { $0.id == categoryID })
        expenseTypes = storage.loadExpenseTypes()
    }
}

private struct YearlyLineGraphView: View {
    let spentValues: [Double]
    let budgetValues: [Double]
    let spentColor: Color

    private let months = Calendar.current.shortMonthSymbols

    var body: some View {
        GeometryReader { geometry in
            let maxValue = max((spentValues + budgetValues).max() ?? 1, 1)

            VStack(spacing: 8) {
                ZStack {
                    Path { path in
                        for index in spentValues.indices {
                            let x = xPosition(index: index, width: geometry.size.width)
                            let y = yPosition(value: spentValues[index], height: 130, maxValue: maxValue)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(spentColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    Path { path in
                        for index in budgetValues.indices {
                            let x = xPosition(index: index, width: geometry.size.width)
                            let y = yPosition(value: budgetValues[index], height: 130, maxValue: maxValue)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color(.systemGray), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }
                .frame(height: 130)

                HStack(spacing: 0) {
                    ForEach(0..<12, id: \.self) { index in
                        Text(String(months[index].prefix(3)))
                            .font(.caption2)
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func xPosition(index: Int, width: CGFloat) -> CGFloat {
        guard spentValues.count > 1 else { return 0 }
        return (CGFloat(index) / CGFloat(spentValues.count - 1)) * width
    }

    private func yPosition(value: Double, height: CGFloat, maxValue: Double) -> CGFloat {
        let normalized = value / maxValue
        return height - (CGFloat(normalized) * height)
    }
}
