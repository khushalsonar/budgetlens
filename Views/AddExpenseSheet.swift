import SwiftUI

struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss

    let category: BudgetCategory
    let expenseTypes: [ExpenseType]
    let onAdd: (Expense) -> Void

    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var selectedExpenseTypeID: UUID?
    @State private var amountError: String?
    @FocusState private var amountFocused: Bool

    private var amount: Double? {
        let normalized = amountText.replacingOccurrences(of: ",", with: "")
        return Double(normalized)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("₹")
                        .font(.title2)
                        .foregroundStyle(Color(.secondaryLabel))

                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 36, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .focused($amountFocused)

                    if let amountError {
                        Text(amountError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.top, 20)

                TextField("What was this for?", text: $note)
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Expense type")
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(expenseTypes) { type in
                                let isSelected = selectedExpenseTypeID == type.id
                                Button {
                                    selectedExpenseTypeID = isSelected ? nil : type.id
                                } label: {
                                    Text(type.name)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            isSelected ? Color(hex: category.colorHex) : Color(.secondarySystemBackground),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(isSelected ? Color(.systemBackground) : Color(.label))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer()

                Button(action: addExpense) {
                    Text("Add")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color(.systemBackground))
                }
            }
            .padding(16)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            amountFocused = true
        }
    }

    private func addExpense() {
        amountError = nil

        guard let amount else {
            amountError = "Enter a valid amount."
            return
        }

        guard amount > 0 else {
            amountError = "Amount must be greater than 0."
            return
        }

        let maxAllowed = category.effectiveBudget * 10
        if maxAllowed > 0, amount > maxAllowed {
            amountError = "Amount cannot exceed 10x the effective budget."
            return
        }

        onAdd(
            Expense(
                amount: amount,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                expenseTypeID: selectedExpenseTypeID
            )
        )
        dismiss()
    }
}
