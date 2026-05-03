import SwiftUI

struct HomeView: View {
    @ObservedObject private var storage = StorageManager.shared
    @Binding var deepLinkCategoryID: UUID?

    @State private var categories: [BudgetCategory] = []
    @State private var categoryToDelete: BudgetCategory?

    @State private var deepLinkNavigate: UUID?

    var body: some View {
        ZStack {

            if categories.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    VStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("No categories yet")
                            .font(.headline)
                        Text("Add one from the + tab")
                            .font(.subheadline)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .background(Color(.systemBackground))
            } else {
                VStack(spacing: 0) {
                    header
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    List {
                        ForEach(categories) { category in
                            NavigationLink {
                                CategoryDetailView(categoryID: category.id)
                            } label: {
                                CategoryCard(category: category)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    categoryToDelete = category
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemBackground))
                }
            }
        }

        // ✅ Correct placement: apply to the ZStack, not inside it
        .navigationDestination(item: $deepLinkNavigate) { id in
            CategoryDetailView(categoryID: id)
        }

        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Delete Category", isPresented: Binding(get: {
            categoryToDelete != nil
        }, set: { newValue in
            if !newValue { categoryToDelete = nil }
        })) {
            Button("Delete", role: .destructive) {
                if let categoryToDelete {
                    storage.deleteCategory(categoryToDelete.id)
                    reloadCategories()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the category and all its expenses.")
        }
        .onAppear(perform: reloadCategories)

        // Updated iOS 17 syntax
        .onChange(of: deepLinkCategoryID) {
            handleDeepLink()
        }

        .onReceive(storage.$dataVersion) { _ in
            reloadCategories()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("BudgetLens")
                .font(.largeTitle.weight(.semibold))
            Text(StorageFormatting.displayMonthYear(from: Date()))
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
        }
    }

    private func reloadCategories() {
        _ = storage.performMonthlyResetIfNeeded()
        categories = storage.loadCategories()
        handleDeepLink()
    }

    private func handleDeepLink() {
        guard let requestedID = deepLinkCategoryID else { return }

        if categories.contains(where: { $0.id == requestedID }) {
            deepLinkNavigate = requestedID
        }

        deepLinkCategoryID = nil
    }
}

#Preview {
    NavigationStack {
        HomeView(deepLinkCategoryID: .constant(nil))
    }
}
