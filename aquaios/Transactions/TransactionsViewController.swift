import UIKit
import PromiseKit

class TransactionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    private var transactions: [Transaction] = []
    private var transactionToken: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString(NSLocalizedString("id_transactions", comment: ""), comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        if hasWallet {
            reloadData()
        }

        transactionToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "transaction"), object: nil, queue: .main, using: onNewTransaction)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let token = transactionToken {
            NotificationCenter.default.removeObserver(token)
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
        }.catch { _ in
            self.showError("Failure on fetch balance")
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
}
