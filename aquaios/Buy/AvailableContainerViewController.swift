import UIKit
import PromiseKit

class AvailableContainerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    enum Exchanges: CaseIterable {
        case Bisq
        case Bitfinex
        case BTCTurk
        case BTSE
        case BullBitcoin
        case HodlHodl
        case Liquiditi
        case SideshiftAI
        case TheRockTrading
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue

        let footerView = Bundle.main.loadNibNamed("AvailableFooterCell", owner: self, options: nil)![0] as? AvailableFooterCell
        footerView?.configure()
        footerView?.click = {
            self.openUri("https://help.blockstream.com/hc/en-us/articles/900000629383-Which-platforms-support-the-Liquid-Network")
        }
        tableView.tableFooterView = footerView
    }
}

extension AvailableContainerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Exchanges.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        switch Exchanges.allCases[indexPath.row] {
        case .Bisq: cell?.textLabel?.text = "Bisq"
        case .Bitfinex: cell?.textLabel?.text = "Bitfinex"
        case .BTCTurk: cell?.textLabel?.text = "BTCTurk"
        case .BTSE: cell?.textLabel?.text = "BTSE"
        case .BullBitcoin: cell?.textLabel?.text = "Bull Bitcoin"
        case .HodlHodl: cell?.textLabel?.text = "Hodl Hodl"
        case .Liquiditi: cell?.textLabel?.text = "Liquiditi"
        case .SideshiftAI: cell?.textLabel?.text = "Sideshift AI"
        case .TheRockTrading: cell?.textLabel?.text = "The Rock Trading"
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Exchanges.allCases[indexPath.row] {
        case .Bisq: openUri("https://bisq.network")
        case .Bitfinex: openUri("https://www.bitfinex.com")
        case .BTCTurk: openUri("https://pro.btcturk.com")
        case .BTSE: openUri("https://www.btse.com")
        case .BullBitcoin: openUri("https://bullbitcoin.com")
        case .HodlHodl: openUri("https://hodlhodl.com")
        case .Liquiditi: openUri("https://liquiditi.io")
        case .SideshiftAI: openUri("https://sideshift.ai")
        case .TheRockTrading: openUri("https://www.therocktrading.com")
        }
    }

    func openUri(_ path: String) {
        let url = URL(string: path)
        UIApplication.shared.open(url!, options: [:])
    }
}
