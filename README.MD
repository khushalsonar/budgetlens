# BudgetLens

A minimal, ad-free personal budget tracker for iOS with a live home screen widget.

Built because every existing app was either paywalled, cluttered with ads, or 
overcomplicated for a simple need — know your budget, track your spending, stay aware.

---

## Features

- **Budget Categories** — create categories with a name, color, and monthly budget
- **Expense Tracking** — log expenses in seconds, optionally tagged by type
- **Expense Types** — define a global list of spending types (Food, Travel, Shopping etc.) reused across all categories
- **Monthly Reset** — budgets reset each month automatically, with unspent amounts carried forward if enabled
- **Spending Chart** — visual breakdown of where you're spending the most by expense type
- **Home Screen Widget** — small and medium widget showing your selected category's remaining budget and progress bar, updated live
- **CSV Export** — export all your expense data to share via Files, Mail, or WhatsApp
- **Dark Mode** — follows system appearance automatically, with a manual override in Settings
- **100% Local** — no account, no cloud, no ads. Data lives on your device and is exported on your terms

<!-- ---

## Screenshots -->

<!-- Add screenshots here after publishing -->

---

## Tech Stack

- Swift + SwiftUI
- WidgetKit (home screen widget)
- UserDefaults with App Groups (shared storage between app and widget)
- No third-party dependencies

---

## Requirements

- iOS 16.0 or later
- Xcode 15 or later (to build from source)

---

## Installation

This app is not on the App Store. To run it on your own device:

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/BudgetLens.git
   ```

2. Open `BudgetLens.xcodeproj` in Xcode

3. In Xcode, add both the `BudgetLens` and `BudgetLensWidget` targets to your 
   Apple Developer account under Signing & Capabilities

4. Add the App Group capability to both targets with the identifier:
   `group.com.personal.budgetlens`

5. Connect your iPhone and press Cmd+R to build and run

---

## Project Structure

```
BudgetLens/
├── Models/
│   ├── BudgetCategory.swift
│   └── Expense.swift
├── Storage/
│   └── StorageManager.swift
├── Views/
│   ├── HomeView.swift
│   ├── CategoryDetailView.swift
│   ├── AddCategorySheet.swift
│   ├── AddExpenseSheet.swift
│   ├── SpendingChartView.swift
│   ├── ExpenseTypesView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── CategoryCard.swift
│       ├── ProgressBarView.swift
│       └── ExpenseRow.swift
BudgetLensWidget/
├── BudgetLensWidget.swift
├── WidgetEntryView.swift
└── WidgetSharedModels.swift
```

---

## How It Was Built

This project was built in a single evening with no prior Swift experience using:

- **Claude** — architecture design, technical spec, debugging guidance, and 
  decision making throughout
- **Cursor** — AI-assisted code generation from the spec
- **GitHub Copilot** — bug fixes and iterative improvements

The entire prompt-to-working-app process is documented on 
[LinkedIn](#) <!-- add your post link -->

---

## Data & Privacy

All data is stored locally on your device using UserDefaults.
No data is sent to any server. No analytics. No tracking.
Deleting the app deletes all data.

---

## License

MIT License — use it, fork it, build on it.

---

*Built for personal use. Shared for anyone who wants it.*