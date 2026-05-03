import SwiftUI

struct CategoryCard: View {
    let category: BudgetCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 12, height: 12)

                Text(category.name)
                    .font(.headline)

                Spacer()

                Text(category.effectiveBudget.currencyINR)
                    .font(.headline)
            }

            ProgressBarView(
                progress: category.progress,
                fillColor: Color(hex: category.colorHex),
                height: 6
            )

            HStack {
                Text("\(category.totalSpent.currencyINR) spent  ·  \(category.remaining.currencyINR) left")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))

                Spacer()

                if category.totalSpent > category.effectiveBudget {
                    Text("Over budget!")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color(.label).opacity(0.05), radius: 4, x: 0, y: 1)
    }
}
