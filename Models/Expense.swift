import Foundation

struct Expense: Codable, Identifiable, Equatable {
    var id: UUID
    var amount: Double
    var note: String
    var date: Date
    var expenseTypeID: UUID?

    init(id: UUID = UUID(), amount: Double, note: String, date: Date = Date(), expenseTypeID: UUID? = nil) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
        self.expenseTypeID = expenseTypeID
    }
}
