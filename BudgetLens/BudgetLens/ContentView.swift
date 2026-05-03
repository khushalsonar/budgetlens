import SwiftUI

private enum AppTab: Hashable {
    case home
    case reports
    case add
    case expenseTypes
    case settings
}

struct ContentView: View {
    @ObservedObject private var storage = StorageManager.shared
    @Binding var deepLinkCategoryID: UUID?

    @State private var selectedTab: AppTab = .home
    @State private var showAddCategorySheet = false

    init(deepLinkCategoryID: Binding<UUID?> = .constant(nil)) {
        self._deepLinkCategoryID = deepLinkCategoryID
    }

    var body: some View {
        TabView(selection: Binding(get: {
            selectedTab
        }, set: { newValue in
            if newValue == .add {
                showAddCategorySheet = true
            } else {
                selectedTab = newValue
            }
        })) {
            NavigationStack {
                HomeView(deepLinkCategoryID: $deepLinkCategoryID)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                SpendingChartView()
            }
            .tabItem {
                Label("Reports", systemImage: "chart.pie.fill")
            }
            .tag(AppTab.reports)

            Color.clear
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                    Text("Add")
                }
                .tint(Color.accentColor)
                .tag(AppTab.add)

            NavigationStack {
                ExpenseTypesView()
            }
            .tabItem {
                Label("Expense Types", systemImage: "tag.fill")
            }
            .tag(AppTab.expenseTypes)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(AppTab.settings)
        }
        .onChange(of: deepLinkCategoryID) { _, newValue in
            if newValue != nil {
                selectedTab = .home
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategorySheet(existingCategoryNames: storage.loadCategories().map(\.name)) { category in
                storage.addCategory(category)
            }
        }
    }
}

#Preview {
    ContentView()
}
