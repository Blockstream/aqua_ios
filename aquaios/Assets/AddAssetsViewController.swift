import UIKit
import PromiseKit

class AddAssetsViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var assets: [Asset] = []
    private var filteredAssets: [Asset] = []
    private var pinnedAssets = [String]()
    private var searchController: AquaSearchController?
    private var showSearchResults = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveButton.round(radius: 26.5)
        reloadData()
        configureTableView()
        configureSearch()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.separatorColor = .black
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue
        let nib = UINib(nibName: "AddAssetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddAssetCell")
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

    func reloadData() {
        self.assets = AquaService.allAssets()
            .filter({ $0.icon != nil })
            .sorted(by: { $0.name ?? "" < $1.name ?? "" })
        self.pinnedAssets = UserDefaults.standard.object(forKey: Constants.Keys.pinnedAssets) as? [String] ?? []
        self.tableView.reloadData()

    }

    @IBAction override func dismissTapped(_ sender: Any) {
        dismissModal(animated: true)
    }

    @IBAction func saveTapped(_ sender: Any) {
        UserDefaults.standard.set(self.pinnedAssets, forKey: Constants.Keys.pinnedAssets)
        dismissModal(animated: true)
        }

    @objc func switchChanged(sender: UISwitch) {
        let row = sender.tag
        let tappedAsset = assets[row]
        if tappedAsset.selectable {
            if !pinnedAssets.contains(tappedAsset.info!.assetId) && sender.isOn {
                pinnedAssets.append(tappedAsset.info!.assetId)
            } else {
                let index = pinnedAssets.firstIndex(of: tappedAsset.info!.assetId)!
                pinnedAssets.remove(at: index)
            }
        }
    }

}

extension AddAssetsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResults {
            return filteredAssets.count
        } else {
            return assets.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let asset = assets[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AddAssetCell") as? AddAssetCell {
            cell.configure(with: asset)
            cell.enableSwitch.tag = indexPath.row
            cell.enableSwitch.isOn = self.pinnedAssets.contains(asset.info?.assetId ?? "")
            cell.enableSwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            return cell
        }
        return UITableViewCell()
    }
}

extension AddAssetsViewController: AquaSearchDelegate {
    func didTapSearch() {
    }

    func didStartSearch() {
    }

    func didTapCancel() {
    }

    func didChangeSearchTet() {
    }
}

extension AddAssetsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredAssets = assets.filter({ (asset: Asset) -> Bool in
            if let name = asset.name, let searchString = searchController.searchBar.text {
                return name.range(of: searchString) != nil
            }
            return true
        })
    }
}
