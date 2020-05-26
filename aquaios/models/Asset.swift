import UIKit

struct Asset {
    var sats: UInt64?
    var icon: UIImage?
    var info: AssetInfo?
    var tag: String!

    var isBTC: Bool {
        return tag == "btc"
    }

    var isLBTC: Bool {
        return tag == Liquid.shared.policyAsset
    }

    var name: String? {
        return info?.name
    }

    var ticker: String? {
        return info?.ticker
    }

    func string() -> String? {
        string(sats ?? 0)
    }

    func string(_ satoshi: UInt64) -> String? {
        let decimal = Decimal(satoshi) / pow(10, precision)
        return formatter.string(from: decimal as NSDecimalNumber)
    }

    func satoshi(_ amount: String) -> UInt64? {
        let number = formatter.number(from: amount)
        if let decimal = number?.decimalValue {
            let converted = decimal * pow(10, precision)
            return UInt64(truncating: converted as NSDecimalNumber)
        }
        return nil
    }

    var precision: Int {
        if let i = info, let p = i.precision {
            return Int(p)
        } else {
            return 0
        }
    }

    var formatter: NumberFormatter {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.maximumFractionDigits = precision
        formatter.minimumFractionDigits = 0
        return formatter
    }
}
