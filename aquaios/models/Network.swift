import Foundation

struct Network: Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case network
        case liquid
        case development
        case txExplorerUrl = "tx_explorer_url"
        case icon
        case mainnet
        case policyAsset = "policy_asset"
    }

    let name: String
    let network: String
    let liquid: Bool
    let mainnet: Bool
    let development: Bool
    let txExplorerUrl: String
    var icon: String?
    var policyAsset: String?
}
