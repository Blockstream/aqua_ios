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

    var isUSDt: Bool {
        return tag == Liquid.shared.usdtId
    }

    var isHighlighted: Bool {
        return Liquid.shared.highlightedAssets.contains(tag)
    }

    var name: String? {
        return info?.name
    }

    var ticker: String? {
        return info?.ticker
    }

    var selectable: Bool {
            return !isBTC && !isLBTC && !isUSDt
        }

    var hasFiatRate: Bool {
        return isBTC || isLBTC
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

extension Asset: Equatable {
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.ticker == rhs.ticker &&
            lhs.tag == rhs.tag
    }
}

extension Array where Element == Asset {
    func sort() -> [Asset] {
        var out = [Asset]()
        if let btc = first(where: { $0.isBTC }) { out.append(btc) }
        if let lbtc = first(where: { $0.isLBTC }) { out.append(lbtc) }
        if let usdt = first(where: { $0.isUSDt }) { out.append(usdt) }
        let withName = filter { !$0.isBTC && !$0.isLBTC && !$0.isUSDt && $0.name != nil }.sorted(by: {$0.name! < $1.name! })
        out.append(contentsOf: withName)
        let noNamed = filter { !$0.isBTC && !$0.isLBTC && !$0.isUSDt && $0.name == nil }
        out.append(contentsOf: noNamed)
        return out
    }
}
