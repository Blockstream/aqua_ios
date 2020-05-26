import Foundation

class Wallet: Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case pointer
        case receiveAddress
        case receivingId = "receiving_id"
        case type
        case satoshi
    }

    let name: String
    let pointer: UInt32
    let receiveAddress: String?
    let receivingId: String
    let type: String
    var satoshi: [String: UInt64]
    var btc: UInt64 { get { return satoshi["btc"]! }}
}
