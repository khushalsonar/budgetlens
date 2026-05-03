import SwiftUI
import WidgetKit

private enum WidgetStorage {
    static let appGroupID = "group.com.personal.budgetlens"
    static let categoriesKey = "budget_categories"
    static let widgetSelectionKey = "widget_selected_category_id"

    static func loadCategories() -> [BudgetCategory] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: categoriesKey),
              let categories = try? JSONDecoder().decode([BudgetCategory].self, from: data) else {
            return []
        }
        return categories
    }

    static func selectedCategoryID() -> UUID? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let idString = defaults.string(forKey: widgetSelectionKey) else {
            return nil
        }
        return UUID(uuidString: idString)
    }
}

struct BudgetLensWidgetEntry: TimelineEntry {
    let date: Date
    let category: BudgetCategory?
}

struct BudgetLensProvider: TimelineProvider {
    func placeholder(in context: Context) -> BudgetLensWidgetEntry {
        BudgetLensWidgetEntry(date: Date(), category: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (BudgetLensWidgetEntry) -> Void) {
        completion(BudgetLensWidgetEntry(date: Date(), category: resolveCategory()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetLensWidgetEntry>) -> Void) {
        let entry = BudgetLensWidgetEntry(date: Date(), category: resolveCategory())
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func resolveCategory() -> BudgetCategory? {
        let categories = WidgetStorage.loadCategories()
        guard !categories.isEmpty else { return nil }

        if let selected = WidgetStorage.selectedCategoryID(),
           let category = categories.first(where: { $0.id == selected }) {
            return category
        }

        return categories.first
    }
}

struct BudgetLensWidget: Widget {
    let kind: String = "BudgetLensWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BudgetLensProvider()) { entry in
            BudgetLensWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)                .widgetURL(URL(string: "budgetlens://category/\(entry.category?.id.uuidString ?? "")"))        }
        .configurationDisplayName("BudgetLens")
        .description("Track a selected category's monthly spending.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    BudgetLensWidget()
} timeline: {
    BudgetLensWidgetEntry(date: .now, category: nil)
}
