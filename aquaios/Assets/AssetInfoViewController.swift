import UIKit

enum AssetInfoCellType {
    case ticker
    case unregistered
    case issuer
    case intro
}

extension AssetInfoCellType: CaseIterable {}

class AssetInfoViewController: BaseViewController {

    var asset: Asset?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var assetInfoCellTypes = AssetInfoCellType.allCases
    private var isBTC: Bool {
        get {
            return asset?.isBTC ?? false
        }
    }
    private var hasAssetInfo: Bool {
        get {
            return asset?.info?.name != nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureTableView()
        setupCellTypes()
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

    func configureTitle() {
        if isBTC {
            titleLabel.text = "Bitcoin"
        } else {
            titleLabel.text = asset?.info?.name ?? "Unregistered Asset"
        }
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .aquaBackgroundBlue
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue
        tableView.allowsSelection = false
        let infoCellNib = UINib(nibName: "AssetInfoCell", bundle: nil)
        let unregisteredCellNib = UINib(nibName: "UnregisteredAssetCell", bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: "AssetInfoCell")
        tableView.register(unregisteredCellNib, forCellReuseIdentifier: "UnregisteredAssetCell")
    }

    func setupCellTypes() {
        if isBTC {
            // Keep only ticker and intro for BTC
            assetInfoCellTypes = [AssetInfoCellType.ticker, AssetInfoCellType.intro]
        } else {
            if asset!.isLBTC {
                assetInfoCellTypes = [AssetInfoCellType.ticker, AssetInfoCellType.issuer, AssetInfoCellType.intro]
            }
            if !hasAssetInfo && !asset!.isLBTC {
                // Keep only unregistered
                assetInfoCellTypes = [AssetInfoCellType.unregistered]
            }
        }
    }
}

extension AssetInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case assetInfoCellTypes.firstIndex(of: .ticker):
            return 50
        case assetInfoCellTypes.firstIndex(of: .intro):
            return 150
        default:
            return 80
        }
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
                cell.setup(title: asset?.info?.ticker ?? (asset?.isBTC ?? false ? "BTC" : ""))
                return cell
            }
        case .unregistered:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UnregisteredAssetCell") as? UnregisteredAssetCell {
                cell.setup(title: "Asset Id", text: asset?.info?.assetId ?? "n.a.")
                return cell
            }
        case .issuer:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                cell.setup(title: "Issuer", text: asset?.info?.entity?.domain ?? (asset?.isLBTC ?? false ? "L-BTC has no issuer and is instead created on the network via a peg-in." : ""))
                return cell
            }
        case .intro:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus semper libero et nulla porta suscipit. Nullam at risus arcu. Sed tincidunt lacus sed elementum suscipit. Vivamus justo est, faucibus tempor nisi quis, malesuada sodales lacus."
                cell.setup(title: "Intro", text: text)
                return cell
            }
        }
        return UITableViewCell()
    }
}
