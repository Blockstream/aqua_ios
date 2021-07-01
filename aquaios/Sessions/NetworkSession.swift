import Foundation

class NetworkSession {
    var session: Session?
    var blockHeight: Int = 0

    init() {
        let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
        try? FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        try? gdkInit(config: ["datadir": url.path])
        session = try! Session(notificationCompletionHandler: newNotification)
    }

    func disconnect() throws {
        try session?.disconnect()
    }

    func login(_ mnemonic: String) throws {
        let call = try session?.login(mnemonic: mnemonic, password: "", hw_device: [:])
        _ = try DummyResolve(call: call!)
    }

    func newNotification(notification: [String: Any]?) {
        let event = notification?["event"] as? String
        switch event {
        case "transaction":
            let data = notification?[event!] as? [String: Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transaction"), object: nil, userInfo: data)
        case "block":
            let data = notification?[event!] as? [String: Any]
            blockHeight = data?["block_height"] as? Int ?? 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "block"), object: nil, userInfo: data)
        default: break
        }
    }

    var wallet: Wallet? {
        let call = try? session?.getSubaccount(subaccount: 0)
        let data = try? DummyResolve(call: call!)
        if let result = data?["result"] as? [String: Any] {
            if let jsonData = try? JSONSerialization.data(withJSONObject: result) {
                return try? JSONDecoder().decode(Wallet.self, from: jsonData)
            }
        }
        return nil
    }

    var balance: [String: UInt64]? {
        let call = try? session?.getBalance(details: ["subaccount": 0, "num_confs": 0])
        let data = try? DummyResolve(call: call!)
        let result = data?["result"] as? [String: UInt64]
        let jsonData = try! JSONSerialization.data(withJSONObject: result!)
        return try? JSONDecoder().decode([String: UInt64].self, from: jsonData)
    }

    var address: String? {
        let call = try? session?.getReceiveAddress(details: ["subaccount": 0])
        let data = try? DummyResolve(call: call!)
        let result = data?["result"] as? [String: Any]
        return result?["address"] as? String
    }

    func getTransactions(first: UInt32 = 0) -> [Transaction] {
        let call = try? session?.getTransactions(details: ["subaccount": 0, "first": first, "count": 100])
        let data = try? DummyResolve(call: call!)
        let result = data?["result"] as? [String: Any]
        let dict = result?["transactions"] as? [[String: Any]]
        let list = dict?.map { tx -> Transaction in
            let jsonData = try! JSONSerialization.data(withJSONObject: tx)
            return try! JSONDecoder().decode(Transaction.self, from: jsonData)
        }
        return list ?? []
    }

    func getDefaultFees() -> UInt64 {
        let fees = try? session?.getFeeEstimates()?["fees"] as? [UInt64]
        return fees?.last ?? 1000
    }

    func getFastFees() -> UInt64 {
        let fees = try? session?.getFeeEstimates()?["fees"] as? [UInt64]
        return fees?[1] ?? 1000
    }

    func createTransaction(_ address: String) throws -> RawTransaction {
        let addressee = Addressee(address: address, satoshi: 0, assetId: nil)
        return try createTransaction(addressee)
    }

    func createTransaction(_ tx: RawTransaction) throws -> RawTransaction {
        let inputTx = (try JSONSerialization.jsonObject(with: JSONEncoder().encode(tx), options: .allowFragments) as? [String: Any])!
        let call = try session!.createTransaction(details: inputTx)
        let data = try DummyResolve(call: call)
        let result = data["result"] as? [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject: result ?? [:])
        return try JSONDecoder().decode(RawTransaction.self, from: jsonData)
    }

    func createTransaction(_ addressee: Addressee, max: Bool = false) throws -> RawTransaction {
        guard let s = session else {
            throw TransactionError.generic("")
        }
        let defaultFee = getDefaultFees()
        let inputAddressee = try JSONSerialization.jsonObject(with: JSONEncoder().encode(addressee), options: .allowFragments) as? [String: Any]
        let input = ["addressees": [inputAddressee], "fee_rate": defaultFee, "subaccount": 0, "send_all": max] as [String: Any]
        let call = try s.createTransaction(details: input)
        let data = try DummyResolve(call: call)
        let result = data["result"] as? [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject: result ?? [:])
        return try JSONDecoder().decode(RawTransaction.self, from: jsonData)
    }

    func sendTransaction(_ tx: RawTransaction) throws -> String {
        guard let session = session else {
            throw TransactionError.generic("Session error")
        }
        let rawTransaction = try JSONSerialization.jsonObject(with: JSONEncoder().encode(tx), options: .allowFragments) as? [String: Any]
        let txCall = try session.createTransaction(details: rawTransaction ?? [:])
        let txData = try DummyResolve(call: txCall)
        let txRes = txData["result"] as? [String: Any]
        if let error = txData["error"] as? String, error != "" {
            throw TransactionError.generic(error)
        }
        let signedCall = try session.signTransaction(details: txRes ?? [:])
        let signedRes = try DummyResolve(call: signedCall)
        let signedTx = signedRes["result"] as? [String: Any]
        if let error = signedTx?["error"] as? String, error != "" {
            throw TransactionError.generic(error)
        }
        guard let txHash = signedTx?["transaction"] as? String else {
            throw TransactionError.generic("txHash error")
        }
        return try session.broadcastTransaction(tx_hex: txHash)
    }
}
