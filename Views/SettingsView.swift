import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme = "system"

    @State private var exportURL: URL?
    @State private var showShareSheet = false

    private let storage = StorageManager.shared

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }

            Section("Data") {
                Button("Export Data as CSV") {
                    exportURL = createCSVExport()
                    showShareSheet = exportURL != nil
                }
            }

            Section("About") {
                LabeledContent("App name", value: "BudgetLens")
                LabeledContent("Version", value: "1.0.0")
                Text("Data is stored locally on your device")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet, onDismiss: cleanupExportFile) {
            if let exportURL {
                ActivityViewController(activityItems: [exportURL])
            }
        }
    }

    private func createCSVExport() -> URL? {
        let categories = storage.loadCategories()
        let expenseTypes = Dictionary(uniqueKeysWithValues: storage.loadExpenseTypes().map { ($0.id, $0.name) })

        var rows: [(date: Date, category: String, amount: Double, note: String, type: String)] = []

        for category in categories {
            for expense in category.expenses {
                rows.append((
                    date: expense.date,
                    category: category.name,
                    amount: expense.amount,
                    note: expense.note,
                    type: expense.expenseTypeID.flatMap { expenseTypes[$0] } ?? "Other"
                ))
            }
        }

        rows.sort { $0.date > $1.date }

        var csv = "Date,Category,Amount,Note,ExpenseType\n"
        for row in rows {
            let date = StorageFormatting.csvDateFormatter.string(from: row.date)
            let amount = StorageFormatting.csvAmountString(row.amount)
            let note = row.note.replacingOccurrences(of: "\"", with: "\"\"")
            let category = row.category.replacingOccurrences(of: "\"", with: "\"\"")
            let type = row.type.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(date)\",\"\(category)\",\(amount),\"\(note)\",\"\(type)\"\n"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_IN")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "BudgetLens_Export_\(dateFormatter.string(from: Date())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private func cleanupExportFile() {
        guard let exportURL else { return }
        try? FileManager.default.removeItem(at: exportURL)
        self.exportURL = nil
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
