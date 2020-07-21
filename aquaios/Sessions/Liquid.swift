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

    override func getTransactions(first: UInt32 = 0) -> [Transaction] {
        let list = super.getTransactions(first: first)
        for var tx in list {
            tx.networkName = Liquid.networkName
        }
        return list
    }
}
