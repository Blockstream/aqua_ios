import UIKit
import PromiseKit

class TransactionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var receiveView: UIView!
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var receiveIconView: UIView!
    @IBOutlet weak var buyIconView: UIView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var receiveDescriptionLabel: UILabel!
    @IBOutlet weak var buyDescriptionLabel: UILabel!

    private var transactions: [Transaction] = []
    private var transactionToken: NSObjectProtocol?
    private var blockToken: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        firstLabel.text = NSLocalizedString("id_new_to_aqua", comment: "")
        secondLabel.text = NSLocalizedString("id_add_assets_to_get_started", comment: "")
        receiveLabel.text = NSLocalizedString("id_receive", comment: "")
        receiveDescriptionLabel.text = NSLocalizedString("id_from_other_wallets", comment: "")
        buyLabel.text = NSLocalizedString("id_buy", comment: "")
        buyDescriptionLabel.text = NSLocalizedString("id_debit_or_apple_pay", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("id_transactions", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        configurePreLogin()
        self.tableView.isHidden = !hasWallet
        self.emptyView.isHidden = hasWallet
        if hasWallet {
            reloadData()
        }

        transactionToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "transaction"), object: nil, queue: .main, using: onNewTransaction)
        blockToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "block"), object: nil, queue: .main, using: onNewBlock)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let token = transactionToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = blockToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func onNewBlock(_ notification: Notification) {
        let pendingTxs = transactions.filter { $0.blockHeight == 0 }
        if !pendingTxs.isEmpty {
            reloadData()
        }
    }

    func onNewTransaction(_ notification: Notification) {
        self.reloadData()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 76
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue
        tableView.separatorColor = .aquaShadowBlue
        let nib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionCell")
    }

    func configurePreLogin() {
        let receiveGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createReceive))
        let buyGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createBuy))
        receiveView.addGestureRecognizer(receiveGestureRecognizer)
        receiveView.isUserInteractionEnabled = true
        buyView.addGestureRecognizer(buyGestureRecognizer)
        buyView.isUserInteractionEnabled = true
        receiveView.round(radius: 24)
        buyView.round(radius: 24)
    }

    @objc func createReceive(_ sender: Any?) {
        if !hasWallet {
            return performSegue(withIdentifier: "create_wallet_alert", sender: nil)
        }
        performSegue(withIdentifier: "receive", sender: nil)
    }

    @objc func createBuy(_ sender: Any?) {
        if !hasWallet {
            return performSegue(withIdentifier: "create_wallet_alert", sender: nil)
        }
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 2
        }
    }

    func txsPromise(_ sharedNetwork: NetworkSession) -> Promise<[Transaction]> {
        return Promise<[Transaction]> { seal in
            seal.fulfill(sharedNetwork.getTransactions())
        }
    }

    func reloadData() {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            return Guarantee()
        }.then(on: bgq) {
            when(fulfilled: self.txsPromise(Bitcoin.shared), self.txsPromise(Liquid.shared))
        }.done { bitcoin, liquid in
            self.transactions = bitcoin + liquid
            self.transactions.sort(by: { $0.createdAt > $1.createdAt })
            self.tableView.reloadData()
            self.tableView.isHidden = self.transactions.isEmpty
            self.emptyView.isHidden = !self.transactions.isEmpty
        }.catch { _ in
            self.showError("Failure on fetch balance")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CreateWalletAlertController {
            dest.delegateVC = self
            return
        }
        let nav = segue.destination as? UINavigationController
        if let dest = nav?.topViewController as? TransactionViewController {
            dest.tx = sender as? Transaction
            dest.updateTransaction = { transaction in
                self.reloadData()
            }
        } else if let dest = nav?.topViewController as? ReceiveViewController {
            dest.asset = Registry.shared.asset(for: "btc")
        }
    }
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {

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

extension TransactionsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        configurePreLogin()
    }
}
