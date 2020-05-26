import UIKit
import Foundation
import PromiseKit

class Registry: Codable {
    static let shared = Registry()
    var infos = [String: AssetInfo]()
    var icons: [String: String]!

    func refresh(_ session: Session) throws -> [String: AssetInfo]? {
        let data = try session.refreshAssets(params: ["icons": true, "assets": true, "refresh": true])
        var infosData = data?["assets"] as? [String: Any]
        let iconsData = data?["icons"] as? [String: String]
        if let modIndex = infosData?.keys.firstIndex(of: "last_modified") {
            infosData?.remove(at: modIndex)
        }
        let infosSer = try? JSONSerialization.data(withJSONObject: infosData ?? [:])
        let infos = try? JSONDecoder().decode([String: AssetInfo].self, from: infosSer ?? Data())
        self.infos = infos ?? [:]
        self.icons = iconsData ?? [:]
        return infos
    }

    func info(for key: String) -> AssetInfo? {
        if key == "btc" {
            return AssetInfo(assetId: key, name: "Bitcoin", precision: 8, ticker: "BTC")
        } else if key == Liquid.shared.policyAsset {
            return AssetInfo(assetId: key, name: "Liquid Bitcoin", precision: 8, ticker: "L-BTC")
        }
        return infos[key]
    }

    func image(for key: String) -> UIImage? {
        if key == "btc" {
            return UIImage(named: "btc")
        } else if let icon = icons[key] {
            return UIImage(base64: icon)
        }
        return UIImage(named: "default_asset_icon")
    }
}
