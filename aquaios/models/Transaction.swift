import Foundation

struct Addressee: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case satoshi
        case assetId = "asset_id"
    }
    var address: String = ""
    var satoshi: UInt64 = 0
    var assetId: String?

    init(address: String, satoshi: UInt64, assetId: String?) {
        self.address = address
        self.satoshi = satoshi
        self.assetId = assetId
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
        case addressees
    }

    let hash: String
    let blockHeight: UInt32
    let createdAt: String
    let fee: UInt64
    var memo: String
    var satoshi: [String: UInt64]
    let type: String
    let addressees: [String]
    var networkName: String = ""

    var defaultAsset: String {
        return AquaService.sort(satoshi).filter { $0.value != 0 }.last!.key
    }

    var incoming: Bool {
        return type == "incoming"
    }

    var outgoing: Bool {
        return type == "outgoing"
    }

    var redeposit: Bool {
        return type == "redeposit"
    }

    init(hash: String, height: UInt32, rawTx: RawTransaction) {
        self.hash = hash
        self.blockHeight = height
        self.createdAt = ""
        self.fee = rawTx.fee ?? 0
        self.memo = ""
        self.satoshi = [rawTx.addressees[0].assetId ?? "": rawTx.addressees[0].satoshi]
        self.type = "outgoing"
        self.addressees = [rawTx.addressees[0].address]
        self.networkName = ""
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
        case memo
    }

    let subaccount: UInt64 = 0
    let fee: UInt64?
    var feeRate: UInt64
    let sendAll: Bool
    var addressees: [Addressee]
    var error: String?
    var memo: String?
}
