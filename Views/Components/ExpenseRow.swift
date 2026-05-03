import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let expenseTypeName: String?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.amount.currencyINR)
                    .font(.headline)

                Text(expense.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))

                if let expenseTypeName {
                    Text(expenseTypeName)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.secondarySystemBackground), in: Capsule())
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }

            Spacer(minLength: 12)

            Text(expense.note.isEmpty ? "-" : expense.note)
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}
