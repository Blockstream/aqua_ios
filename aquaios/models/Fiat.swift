import Foundation

class Fiat {

    static func rate() -> Double? {
        let res = try? Bitcoin.shared.session?.convertAmount(input: ["satoshi": 1])
        if let rate = res?["fiat_rate"] as? String {
            return Double(rate)
        }
        return nil
    }

    static func currency() -> String? {
        let res = try? Bitcoin.shared.session?.convertAmount(input: ["satoshi": 1])
        return res?["fiat_currency"] as? String
    }

    static func from(_ satoshi: UInt64) -> String? {
        guard let rate = rate() else { return nil }
        let decimal = Decimal(satoshi) / pow(10, 8) * Decimal(rate)
        return formatter.string(from: decimal as NSDecimalNumber)
    }

    static func to(_ amount: String) -> UInt64? {
        guard let rate = rate() else { return nil }
        let number = formatter.number(from: amount)?.decimalValue
        var decimal = number! * pow(10, 8) / Decimal(rate)
        var drounded: Decimal = Decimal()
        NSDecimalRound(&drounded, &decimal, 0, .plain)
        return NSDecimalNumber(decimal: drounded).uint64Value
    }

    static var formatter: NumberFormatter {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.generatesDecimalNumbers = true
        return formatter
    }

}
