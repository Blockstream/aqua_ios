import XCTest

@testable import Aqua

class AquaTests: XCTestCase {
    let liquid = Liquid()

    override func setUp() {
        let mnemonic = try! generateMnemonic()
        try? liquid.connect()
        try? liquid.register(mnemonic)
        try? liquid.login(mnemonic)
    }

    override func tearDown() {
        try? liquid.disconnect()
    }

    func testWallet() {
        let wallet = liquid.wallet
        XCTAssertNotNil(wallet)
    }

    func testBalance() {
        let balance = liquid.balance
        XCTAssertNotNil(balance)
    }

    func testAddress() {
        let address = liquid.address
        XCTAssertNotNil(address)
    }

    func testNetwork() {
        let network = liquid.network
        XCTAssertNotNil(network)
        XCTAssertTrue(network.liquid)
        XCTAssertTrue(network.mainnet)
        XCTAssertFalse(network.development)
        XCTAssertEqual("liquid", network.network, "invalid network")
    }

    func testTransactions() {
        let txs = liquid.getTransactions(first: 0)
        XCTAssertNotNil(txs)
        XCTAssertTrue(txs.size > 0)
    }

    func testRegistry() {
        let assets = try? Registry.shared.refresh(liquid.session!)
        XCTAssertNotNil(assets)
        XCTAssertTrue(assets!.count > 0)
    }
}
