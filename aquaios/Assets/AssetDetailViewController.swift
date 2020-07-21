import UIKit
import PromiseKit

class AssetDetailViewController: BaseViewController {

    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var curlyArrow: UIImageView!
    @IBOutlet weak var exchangePromptLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!

    var asset: Asset?
    private var transactions: [Transaction] = []
    private var transactionToken: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        transactionToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "transaction"), object: nil, queue: .main, using: onNewTransaction)

        configureView()
        configureTableView()
        reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let token = transactionToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func onNewTransaction(_ notification: Notification) {
        self.reloadBalance()
        self.reloadData()
        self.showBackupIfNotified()
    }

    func configureView() {
        if let asset = asset {
            let titleView = AssetTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 22))
            titleView.configure(with: asset)
            navigationItem.titleView = titleView
            buyButton.isHidden = !(asset.isBTC || asset.isLBTC)
            balanceLabel.text = "\(asset.string() ?? "")"
            tickerLabel.text = asset.ticker ?? ""
            fiatLabel.text = ""
            if !asset.selectable {
                let fiat = Fiat.from(asset.sats ?? 0)
                fiatLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
            }
            let infoButton = UIBarButtonItem(image: UIImage(named: "info"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(infoButtonTapped))
            navigationItem.rightBarButtonItem = infoButton
        }

        buyButton.round(radius: 24, borderWidth: 2, borderColor: .auroMetalSaurus)
        sendButton.round(radius: 24)
        receiveButton.round(radius: 24)
        sendButton.setTitle(NSLocalizedString("id_send", comment: ""), for: .normal)
        receiveButton.setTitle(NSLocalizedString("id_receive", comment: ""), for: .normal)

        // Hidden for beta one
        for view in [exchangePromptLabel, curlyArrow, buyButton] {
            view?.isHidden = true
        }
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .aquaShadowBlue
        let cellNib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "TransactionCell")
    }

    func reloadBalance() {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            return Guarantee()
        }.compactMap(on: bgq) {
            return self.asset?.isBTC ?? false ? Bitcoin.shared.balance : Liquid.shared.balance
        }.done { balance in
            self.asset = AquaService.assets(for: balance.filter({ $0.key == self.asset?.info?.assetId })).first
            self.balanceLabel.text = "\(self.asset?.string() ?? "")"
            let fiat = Fiat.from(self.asset?.sats ?? 0)
            self.fiatLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }.catch { _ in
            let alert = UIAlertController(title: NSLocalizedString("id_error", comment: ""), message: "No balance found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("id_retry", comment: ""), style: .default, handler: { _ in self.reloadData() }))
            self.present(alert, animated: true)
        }
    }

    func reloadData() {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            return Guarantee()
        }.compactMap(on: bgq) {
            return self.asset?.isBTC ?? false ? Bitcoin.shared.getTransactions() : Liquid.shared.getTransactions()
        }.ensure {
            self.stopAnimating()
        }.done { transactions in
            self.transactions = transactions.filter { $0.satoshi.contains { $0.key == self.asset!.tag } }
            self.transactions.sort(by: { $0.createdAt > $1.createdAt })
            self.tableView.isHidden = self.transactions.count == 0
            self.tableView.reloadData()
        }.catch { _ in
            let alert = UIAlertController(title: NSLocalizedString("id_error", comment: ""), message: "No Transactions Found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("id_retry", comment: ""), style: .default, handler: { _ in self.reloadData() }))
            self.present(alert, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else {
            return
        }
        if let dest = nav.topViewController as? SendAddressViewController {
            dest.asset = sender as? Asset
        } else if let dest = nav.topViewController as? ReceiveViewController {
            dest.asset = sender as? Asset
            dest.showCloseButton = true
        } else if let dest = nav.topViewController as? AssetInfoViewController {
            dest.asset = sender as? Asset
        } else if let dest = nav.topViewController as? TransactionViewController {
            dest.tx = sender as? Transaction
        }
    }

    @objc func infoButtonTapped() {
        performSegue(withIdentifier: "asset_info", sender: asset)
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "detail_send", sender: asset)
    }

    @IBAction func receiveButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "detail_receive", sender: asset)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension AssetDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tx = transactions[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell {
            cell.configure(with: tx)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tx = transactions[indexPath.row]
        performSegue(withIdentifier: "transaction", sender: tx)
    }
}
