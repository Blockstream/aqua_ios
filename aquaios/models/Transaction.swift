import Foundation

struct Addressee: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case satoshi
        case assetTag = "asset_tag"
    }
    var address: String = ""
    var satoshi: UInt64 = 0
    var assetTag: String?

    init(address: String, satoshi: UInt64, assetTag: String?) {
        self.address = address
        self.satoshi = satoshi
        self.assetTag = assetTag
    }
}

struct Transaction: Codable {

    enum CodingKeys: String, CodingKey {
        case hash = "txhash"
        case blockHeight = "block_height"
        case createdAt = "created_at"
        case fee
        case memo
        case satoshi
        case type
    }

    let hash: String
    let blockHeight: UInt32
    let createdAt: String
    let fee: UInt64
    let memo: String
    var satoshi: [String: UInt64]
    let type: String

    var defaultAsset: String {
        return AquaService.sort(satoshi).filter { $0.key != "btc" }.first?.key ?? "btc"
    }
}

struct RawTransaction: Codable {

    enum CodingKeys: String, CodingKey {
        case subaccount
        case fee
        case feeRate = "fee_rate"
        case sendAll = "send_all"
        case addressees
        case error
    }

    let subaccount: UInt64 = 0
    let fee: UInt64?
    var feeRate: UInt64
    let sendAll: Bool
    var addressees: [Addressee]
    var error: String?
}
