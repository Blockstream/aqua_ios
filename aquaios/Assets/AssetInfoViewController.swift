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
    @IBOutlet weak var copiedButton: UIButton!

    private var assetInfoCellTypes = AssetInfoCellType.allCases
    private var isBTC: Bool {
        get {
            return asset?.isBTC ?? false
        }
    }
    private var isLBTC: Bool {
        get {
            return asset?.isLBTC ?? false
        }
    }
    private var isUSDt: Bool {
        get {
            return asset?.isUSDt ?? false
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
        copiedButton.alpha = 0.0
        copiedButton.round(radius: 17.5)
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
        let infoCellNib = UINib(nibName: "AssetInfoCell", bundle: nil)
        let unregisteredCellNib = UINib(nibName: "UnregisteredAssetCell", bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: "AssetInfoCell")
        tableView.register(unregisteredCellNib, forCellReuseIdentifier: "UnregisteredAssetCell")
    }

    func setupCellTypes() {
        if isBTC {
            // Keep only ticker and intro for BTC
            assetInfoCellTypes = [AssetInfoCellType.ticker, AssetInfoCellType.intro]
            return
        } else if !hasAssetInfo && !isLBTC {
            // Keep only unregistered
            assetInfoCellTypes = [AssetInfoCellType.unregistered]
        } else if !(isLBTC || isUSDt) {
            // Only BTC, LBTC, USDt have intros
            assetInfoCellTypes.remove(at: assetInfoCellTypes.firstIndex(of: AssetInfoCellType.intro)!)
        } else if isLBTC {
            assetInfoCellTypes.remove(at: assetInfoCellTypes.firstIndex(of: AssetInfoCellType.unregistered)!)
        }
    }

    func getIntroId() -> String {
        if isBTC {
            return "id_bitcoin_is_a_decentralized"
        } else if isLBTC {
            return "id_liquid_bitcoin_lbtc_represents"
        } else if isUSDt {
            return "id_tether_is_a_blockchainenabled"
        }
        return ""
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
                cell.setup(title: NSLocalizedString("id_asset_id", comment: ""), text: asset?.tag ?? "n.a.")
                return cell
            }
        case .issuer:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                cell.setup(title: NSLocalizedString("id_issuer", comment: ""), text: asset?.info?.entity?.domain ?? (asset?.isLBTC ?? false ? NSLocalizedString("id_lbtc_has_no_issuer_and_is", comment: "") : ""))
                return cell
            }
        case .intro:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AssetInfoCell") as? AssetInfoCell {
                let text = NSLocalizedString(getIntroId(), comment: "")
                cell.setup(title: NSLocalizedString("id_intro", comment: ""), text: text)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if assetInfoCellTypes[indexPath.row] == .unregistered {
            copiedButton.fadeInOut()
            UIPasteboard.general.string = asset?.tag ?? ""
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
