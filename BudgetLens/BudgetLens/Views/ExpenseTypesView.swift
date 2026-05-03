import SwiftUI

struct ExpenseTypesView: View {
    @State private var expenseTypes: [ExpenseType] = []
    @State private var showAddSheet = false

    private let storage = StorageManager.shared

    var body: some View {
        List {
            ForEach(expenseTypes) { type in
                Text(type.name)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if expenseTypes.count > 1 {
                                storage.deleteExpenseType(type.id)
                                reloadTypes()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(expenseTypes.count <= 1)
                    }
            }
        }
        .navigationTitle("Expense Types")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddExpenseTypeSheet(existingNames: expenseTypes.map(\.name)) { type in
                storage.addExpenseType(type)
                reloadTypes()
            }
        }
        .onAppear(perform: reloadTypes)
    }

    private func reloadTypes() {
        expenseTypes = storage.loadExpenseTypes()
    }
}

private struct AddExpenseTypeSheet: View {
    @Environment(\.dismiss) private var dismiss

    let existingNames: [String]
    let onSave: (ExpenseType) -> Void

    @State private var name = ""
    @State private var nameError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Type name", text: $name)
                    .textFieldStyle(.roundedBorder)

                if let nameError {
                    Text(nameError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                Button {
                    save()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color(.systemBackground))
                }
            }
            .padding(16)
            .navigationTitle("Add Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        nameError = nil
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            nameError = "Name is required."
            return
        }

        if existingNames.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            nameError = "An expense type with this name already exists."
            return
        }

        onSave(ExpenseType(name: trimmed))
        dismiss()
    }
}
