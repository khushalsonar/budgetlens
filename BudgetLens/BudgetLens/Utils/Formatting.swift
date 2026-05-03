import Foundation
import SwiftUI

enum StorageFormatting {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    static let csvDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter
    }()

    static func monthString(from date: Date) -> String {
        monthFormatter.string(from: date)
    }

    static func displayMonthYear(from date: Date) -> String {
        monthYearFormatter.string(from: date)
    }

    static func displayMonthYear(from monthKey: String) -> String {
        guard let date = monthFormatter.date(from: monthKey) else { return displayMonthYear(from: Date()) }
        return monthYearFormatter.string(from: date)
    }

    static func previousMonthName(from monthKey: String) -> String? {
        guard let date = monthFormatter.date(from: monthKey),
              let previous = Calendar.current.date(byAdding: .month, value: -1, to: date) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: previous)
    }

    static func decimalString(from value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }

    static func csvAmountString(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

extension Double {
    var currencyINR: String {
        StorageFormatting.currencyFormatter.string(from: NSNumber(value: self)) ?? "₹0"
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
