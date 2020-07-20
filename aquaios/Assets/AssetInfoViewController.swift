import UIKit

enum AssetInfoCellType {
    case ticker
    case unregistered
    case issuanceDate
    case community
    case intro
}

extension AssetInfoCellType: CaseIterable {}

class AssetInfoViewController: BaseViewController {

    var asset: Asset?

    @IBOutlet weak var tableView: UITableView!

    private var assetInfoCellTypes = AssetInfoCellType.allCases
    private var isLiquid: Bool {
        get {
            return !(asset?.isBTC ?? false)
        }
    }
    private var hasAssetInfo: Bool {
        get {
            return asset?.info == nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellTypes()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCloseButton(on: .left)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension // do I need this?
        tableView.estimatedRowHeight = 75 // do I need this?
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .aquaBackgroundBlue
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue
        let cellNib = UINib(nibName: "AssetInfoCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "AssetInfoCell")
    }

    func setupCellTypes() {
        if !isLiquid {
            // Keep only ticker and intro for BTC
            assetInfoCellTypes.removeSubrange(1...3)
        } else {
            if !hasAssetInfo {
                // Keep only unregistered
                assetInfoCellTypes.removeAll(where: { $0 != AssetInfoCellType.unregistered })
            }
        }
    }
}

extension AssetInfoViewController: UITableViewDataSource, UITableViewDelegate {
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
        return assetInfoCellTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch assetInfoCellTypes[indexPath.row] {
        case .ticker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                cell.setup(title: "L-BTC")
                return cell
            }
        case .unregistered:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                    cell.setup(title: "Issuer", text: "1:1 Peg with Bitcoin")
                return cell
            }
        case .issuanceDate:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                cell.setup(title: "L-BTC")
                return cell
            }
        case .community:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                cell.setup(title: "L-BTC")
                return cell
            }
        case .intro:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                cell.setup(title: "L-BTC")
                return cell
            }
        }
        return UITableViewCell()
    }
}
