import SwiftUI

@main
struct BudgetLensApp: App {
    @AppStorage("appTheme") private var appTheme = "system"
    @State private var deepLinkCategoryID: UUID?

    var body: some Scene {
        WindowGroup {
            ContentView(deepLinkCategoryID: $deepLinkCategoryID)
                .preferredColorScheme(themeColorScheme)
                .onOpenURL { url in
                    guard url.scheme == "budgetlens" else { return }
                    let idString = url.lastPathComponent
                    guard let categoryID = UUID(uuidString: idString) else { return }
                    deepLinkCategoryID = categoryID
                }
        }
    }

    private var themeColorScheme: ColorScheme? {
        switch appTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}
