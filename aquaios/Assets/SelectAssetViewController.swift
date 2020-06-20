import UIKit
import PromiseKit

class SelectAssetViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var flow: TxFlow!
    var addressee: Addressee?

    private var assets = [Asset]()
    private var sendAssets = [Asset]()
    private var receivedAssets = [Asset]()
    private var balance = [String: UInt64]()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = flow == .send ?  "Choose Asset" : "Select Asset"
        if flow == .receive {
            showCloseButton(on: .left)
        }
        reloadData()
        configureTableView()
        configureSearch()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 86
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .black
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue
        let nib = UINib(nibName: "AssetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AssetCell")
    }

    func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.appearance()
        tableView.tableHeaderView = searchController.searchBar
    }

    func balancePromise(_ sharedNetwork: NetworkSession) -> Promise<[String: UInt64]> {
        return Promise<[String: UInt64]> { seal in
            seal.fulfill(sharedNetwork.balance ?? [:])
        }
    }

    func reloadData() {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            return Guarantee()
        }.then(on: bgq) {
            when(fulfilled: self.balancePromise(Bitcoin.shared), self.balancePromise(Liquid.shared))
        }.ensure {
            self.stopAnimating()
        }.done { bitcoin, liquid in
            if self.flow! == .send {
                self.sendAssets = AquaService.assets(for: liquid).sort()
                self.assets = self.sendAssets
            } else {
                let pinned = UserDefaults.standard.object(forKey: Constants.Keys.pinnedAssets) as? [String] ?? []
                let all = Registry.shared.list.map { ($0, UInt64(0)) }
                var list = bitcoin.merging(liquid) { (_, new) in new }
                list = list.merging(all) { (old, _) in old }
                self.receivedAssets = AquaService.assets(for: list).sort()
                self.assets = self.receivedAssets.filter { $0.isBTC || $0.isLBTC || $0.sats ?? 0 > 0 || pinned.contains($0.tag) }
            }
            self.tableView.reloadData()
        }.catch { _ in
            let alert = UIAlertController(title: "Error", message: "Failure on fetch balance", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.reloadData() }))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ReceiveViewController {
            dest.asset = sender as? Asset
        } else if let dest = segue.destination as? SendDetailsViewController {
            let asset = sender as? Asset
            addressee?.assetTag = asset!.tag
            dest.addressee = addressee
        }
    }
}

extension SelectAssetViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let asset = assets[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell") as? AssetCell {
            cell.configure(with: asset)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let asset = assets[indexPath.row]
        self.searchController.isActive = false
        switch flow {
        case .send:
            performSegue(withIdentifier: "select_send", sender: asset)
        case .receive:
            performSegue(withIdentifier: "select_receive", sender: asset)
        case .none:
            dismissModal(animated: true)
        }
    }
}

extension SelectAssetViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let list = flow! == .receive ? receivedAssets : sendAssets
        if let searchText = searchController.searchBar.text,
                !searchText.isEmpty {
            assets = list.filter {
                $0.tag.contains(searchText) ||
                ($0.name?.contains(searchText) ?? false) ||
                ($0.ticker?.contains(searchText) ?? false) }
        } else if flow! == .send {
            assets = list
        } else {
            let pinned = UserDefaults.standard.object(forKey: Constants.Keys.pinnedAssets) as? [String] ?? []
            assets = self.receivedAssets.filter { $0.isBTC || $0.isLBTC || $0.sats ?? 0 > 0 || pinned.contains($0.tag) }
        }
        tableView.reloadData()
    }
}
