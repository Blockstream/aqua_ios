import UIKit
import PromiseKit

class AddAssetsViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var assets = [Asset]()
    private var pinnedAssets = [String]()
    private let searchController = UISearchController(searchResultsController: nil)

    private var allAssets = {
        Registry.shared.assets.sort()
    }()

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
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.appearance()
        tableView.tableHeaderView = searchController.searchBar
    }

    func reloadData() {
        self.assets = allAssets.filter({ $0.icon != nil })
        self.pinnedAssets = UserDefaults.standard.object(forKey: Constants.Keys.pinnedAssets) as? [String] ?? []
        self.tableView.reloadData()
    }

    @IBAction override func dismissTapped(_ sender: Any) {
        self.searchController.isActive = false
        dismissModal(animated: true)
    }

    @IBAction func saveTapped(_ sender: Any) {
        UserDefaults.standard.set(self.pinnedAssets, forKey: Constants.Keys.pinnedAssets)
        self.searchController.isActive = false
        dismissModal(animated: true)
    }

    @objc func switchChanged(sender: UISwitch) {
        let row = sender.tag
        let tappedAsset = assets[row]
        if sender.isOn {
            if !pinnedAssets.contains(tappedAsset.tag) {
                pinnedAssets.append(tappedAsset.tag)
            }
        } else {
            pinnedAssets.removeAll(where: { $0 == tappedAsset.tag })
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
        return assets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let asset = assets[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AddAssetCell") as? AddAssetCell {
            cell.configure(with: asset)
            cell.enableSwitch.tag = indexPath.row
            cell.enableSwitch.isEnabled = asset.selectable
            cell.enableSwitch.isOn = !asset.selectable || self.pinnedAssets.contains(asset.tag ?? "")
            cell.enableSwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            return cell
        }
        return UITableViewCell()
    }
}

extension AddAssetsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
                !searchText.isEmpty {
            assets = allAssets.filter {
                $0.tag.contains(searchText) ||
                ($0.name?.contains(searchText) ?? false) ||
                ($0.ticker?.contains(searchText) ?? false) }
        } else {
            assets = allAssets.filter({ $0.icon != nil })
        }
        tableView.reloadData()
    }
}
