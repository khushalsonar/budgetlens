import SwiftUI

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss

    let existingCategory: BudgetCategory?
    let existingCategoryNames: [String]
    let onSave: (BudgetCategory) -> Void

    @State private var name: String = ""
    @State private var budgetText: String = ""
    @State private var selectedHex: String = CategoryColor.presets.first?.hex ?? "#FF6B6B"
    @State private var allowCarryover = true
    @State private var nameError: String?
    @State private var budgetError: String?

    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case budget
    }

    init(existingCategory: BudgetCategory? = nil, existingCategoryNames: [String], onSave: @escaping (BudgetCategory) -> Void) {
        self.existingCategory = existingCategory
        self.existingCategoryNames = existingCategoryNames
        self.onSave = onSave

        _name = State(initialValue: existingCategory?.name ?? "")
        if let budget = existingCategory?.budget {
            _budgetText = State(initialValue: StorageFormatting.decimalString(from: budget))
        } else {
            _budgetText = State(initialValue: "")
        }
        _selectedHex = State(initialValue: existingCategory?.colorHex ?? (CategoryColor.presets.first?.hex ?? "#FF6B6B"))
        _allowCarryover = State(initialValue: existingCategory?.allowCarryover ?? true)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Category name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .name)

                    if let nameError {
                        Text(nameError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("₹")
                            .foregroundStyle(Color(.secondaryLabel))
                        TextField("Monthly budget", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .budget)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))

                    if let budgetError {
                        Text(budgetError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Toggle("Allow carryover", isOn: $allowCarryover)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Pick a color")
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))

                    HStack(spacing: 12) {
                        ForEach(CategoryColor.presets) { color in
                            let isSelected = color.hex == selectedHex
                            Circle()
                                .fill(Color(hex: color.hex))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? Color.primary : .clear, lineWidth: 2)
                                        .padding(-3)
                                )
                                .onTapGesture {
                                    selectedHex = color.hex
                                }
                        }
                    }
                }

                Spacer()

                Button(action: save) {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color(.systemBackground))
                }
            }
            .padding(16)
            .navigationTitle(existingCategory == nil ? "Add Category" : "Edit Category")
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
            focusedField = .name
        }
    }

    private func save() {
        nameError = nil
        budgetError = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            nameError = "Name is required."
        }

        let duplicate = existingCategoryNames.contains { $0.caseInsensitiveCompare(trimmedName) == .orderedSame }
        if !trimmedName.isEmpty && duplicate {
            nameError = "A category with this name already exists."
        }

        let normalizedBudget = budgetText.replacingOccurrences(of: ",", with: "")
        guard let budget = Double(normalizedBudget) else {
            budgetError = "Enter a valid budget amount."
            return
        }

        guard budget > 0 else {
            budgetError = "Budget must be greater than 0."
            return
        }

        guard nameError == nil else { return }

        let category = BudgetCategory(
            id: existingCategory?.id ?? UUID(),
            name: trimmedName,
            budget: budget,
            expenses: existingCategory?.expenses ?? [],
            colorHex: selectedHex,
            currentMonth: existingCategory?.currentMonth ?? StorageFormatting.monthString(from: Date()),
            carriedOver: existingCategory?.carriedOver ?? 0,
            allowCarryover: allowCarryover
        )

        onSave(category)
        dismiss()
    }
}

struct CategoryColor: Identifiable {
    let id = UUID()
    let hex: String

    static let presets: [CategoryColor] = [
        CategoryColor(hex: "#FF6B6B"),
        CategoryColor(hex: "#FFB347"),
        CategoryColor(hex: "#87BBA2"),
        CategoryColor(hex: "#5BC0EB"),
        CategoryColor(hex: "#9B89C4"),
        CategoryColor(hex: "#F4A0B0"),
        CategoryColor(hex: "#7A8C9E"),
        CategoryColor(hex: "#C8A97E")
    ]
}
