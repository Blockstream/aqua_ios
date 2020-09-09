import Foundation

class Liquid: NetworkSession {
    static let shared = Liquid()
    static let networkName = "liquid-electrum-mainnet"

    var network: Network {
        let networks = try! getNetworks()
        let liquid = networks![Liquid.networkName] as? [String: Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: liquid!)
        return try! JSONDecoder().decode(Network.self, from: jsonData)
    }

    func connect() throws {
        try session?.connect(netParams: ["name": Liquid.networkName, "use_tor": false, "log_level": "debug"])
    }

    var policyAsset: String {
        return network.policyAsset!
    }

    var usdtId: String {
        return "ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2"
    }

    var highlightedAssets: [String] {
        let list = ["b00b0ff0b11ebd47f7c6f57614c046dbbd204e84bf01178baf2be3713a206eb7",
                    "f59c5f3e8141f322276daa63ed5f307085808aea6d4ef9ba61e28154533fdec7",
                    "0e99c1a6da379d1f4151fb9df90449d40d0608f6cb33a5bcbfc8c265f42bab0a",
                    "d9f6bb516c9f3ab16bed3f3662ae018573ee6b00130f2347a4b735d8e7c4c396"]
        return list
    }

    override func getTransactions(first: UInt32 = 0) -> [Transaction] {
        var list = super.getTransactions(first: first)
        if list.isEmpty {
            return list
        }
        for i in 0...list.count-1 {
            list[i].networkName = Liquid.networkName
        }
        return list
    }
}
