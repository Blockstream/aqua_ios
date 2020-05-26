import Foundation

class Bitcoin: NetworkSession {
    static let shared = Bitcoin()
    static let networkName = "electrum-testnet"

    var network: Network {
        let networks = try! getNetworks()
        let liquid = networks![Bitcoin.networkName] as? [String: Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: liquid!)
        return try! JSONDecoder().decode(Network.self, from: jsonData)
    }

    func connect() throws {
        try session?.connect(netParams: ["name": Bitcoin.networkName, "use_tor": false, "log_level": "debug"])
    }
}
