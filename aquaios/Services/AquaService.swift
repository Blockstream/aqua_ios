import Foundation
import UIKit

struct AquaService {

    static func assets(for balance: [String: UInt64]) -> [Asset] {
        let satoshi = sort(balance)
        var assets: [Asset] = []
        for item in satoshi {
            var asset = Asset()
            asset.tag = item.key
            asset.info = Registry.shared.info(for: item.key)
            asset.icon = Registry.shared.image(for: item.key)
            asset.sats = item.value
            assets.append(asset)
        }
        return assets
    }

    static func sort<T>(_ dict: [String: T]) -> [(key: String, value: T)] {
        var sorted = dict.filter {$0.key != "btc" && $0.key != Liquid.shared.policyAsset && $0.key != Liquid.shared.usdtId }.sorted(by: {$0.0 < $1.0 })
        if dict.contains(where: { $0.key == Liquid.shared.usdtId }) {
            sorted.insert((key: Liquid.shared.usdtId, value: dict[Liquid.shared.usdtId]!), at: 0)
        }
        if dict.contains(where: { $0.key == Liquid.shared.policyAsset }) {
            sorted.insert((key: Liquid.shared.policyAsset, value: dict[Liquid.shared.policyAsset]!), at: 0)
        }
        if dict.contains(where: { $0.key == "btc" }) {
            sorted.insert((key: "btc", value: dict["btc"]!), at: 0)
        }
        return Array(sorted)
    }

    static func date(from string: String,
                     dateStyle: DateFormatter.Style = .medium,
                     timeStyle: DateFormatter.Style = .none) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: string) else {
            return string
        }
        return DateFormatter.localizedString(from: date, dateStyle: dateStyle, timeStyle: timeStyle)
    }
}
