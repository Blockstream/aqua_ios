import UIKit
import PromiseKit

class SelectAssetViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var flow: TxFlow!
    var addressee: Addressee?
    private var assets: [Asset] = []
    private var filteredAssets: [Asset] = []
    private var searchController: AquaSearchController?
    private var showSearchResults = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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
        searchController = AquaSearchController(searchResultsController: nil, delegate: self)
        if let searchController = searchController {
            searchController.configureBar(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48),
                                          placeholder: "Search assets...",
                                          font: UIFont.systemFont(ofSize: 18, weight: .medium),
                                          textColor: .auroMetalSaurus,
                                          tintColor: .aquaBackgroundBlue)
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            tableView.tableHeaderView = searchController.aquaSearchBar
        }
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
            var balance = liquid
            if self.flow == TxFlow.receive {
                balance = bitcoin.merging(liquid) { (_, new) in new }
            }
            self.assets = AquaService.assets(for: balance)
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

extension SelectAssetViewController: AquaSearchDelegate {
    func didTapSearch() {
    }

    func didStartSearch() {
    }

    func didTapCancel() {
    }

    func didChangeSearchTet() {
    }
}

extension SelectAssetViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredAssets = assets.filter({ (asset: Asset) -> Bool in
            if let name = asset.name, let searchString = searchController.searchBar.text {
                return name.range(of: searchString) != nil
            }
            return true
        })
    }
}
