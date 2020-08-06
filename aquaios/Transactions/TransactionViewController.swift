import Foundation
import UIKit

enum TxField {
    case amount
    case asset
    case fee
    case notes
    case middleSeparator
    case sentFrom
    case id
    case finalSeparator
}

class TransactionViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copiedButton: UIButton!

    var tx: Transaction!
    private var fields = [TxField]()
    private var headerView: TransactionHeaderCell?
    private var footerView: TransactionFooterCell?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .darkBlueGray
            barAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            barAppearance.shadowColor = .clear
            barAppearance.shadowImage = UIImage()
            navigationController?.navigationBar.standardAppearance = barAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        }
        navigationController?.navigationBar.backgroundColor = .darkBlueGray
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layoutIfNeeded()
        showCloseButton(on: .left)
        copiedButton.alpha = 0.0
        copiedButton.round(radius: 17.5)
        configureTableView()
        reload()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 8
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .aquaBackgroundBlue
        tableView.backgroundView?.backgroundColor = .aquaBackgroundBlue
        tableView.separatorColor = .aquaShadowBlue
        headerView = Bundle.main.loadNibNamed("TransactionHeaderCell", owner: self, options: nil)![0] as? TransactionHeaderCell
        footerView = Bundle.main.loadNibNamed("TransactionFooterCell", owner: self, options: nil)![0] as? TransactionFooterCell
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        headerView?.configure(with: tx)
        footerView?.configure(with: tx)
    }

    func reload() {
        fields = [TxField.amount, TxField.asset]
        fields += (tx.outgoing || tx.redeposit ? [TxField.fee] : [])
        fields += [TxField.notes, TxField.middleSeparator]
        fields += (tx.outgoing ? [TxField.sentFrom] : [])
        fields += [TxField.id, TxField.finalSeparator]
    }

    @objc func copyId() {
        copiedButton.fadeInOut()
        UIPasteboard.general.string = self.tx.hash
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

extension TransactionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]

        switch field {
        case .amount:
            let tag = tx.defaultAsset
            let amount = tx.satoshi[tag] ?? 0
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.textLabel?.text = NSLocalizedString("id_amount", comment: "")
            cell?.detailTextLabel?.text = "\(asset.string(amount) ?? "") \(asset.ticker ?? "")"
            return cell ?? UITableViewCell()
        case .asset:
            let tag = tx.defaultAsset
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.textLabel?.text = NSLocalizedString("id_asset", comment: "")
            cell?.detailTextLabel?.text = asset.name ?? tag
            return cell ?? UITableViewCell()
        case .fee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            let tag = tx.networkName == Liquid.networkName ? Liquid.shared.policyAsset : "btc"
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            cell?.textLabel?.text = NSLocalizedString("id_fee", comment: "")
            cell?.detailTextLabel?.text = "\(asset.string(tx.fee ) ?? "") \(asset.ticker ?? "")"
            return cell ?? UITableViewCell()
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.textLabel?.text = NSLocalizedString("id_notes", comment: "")
            cell?.detailTextLabel?.text = "\(tx.memo)"
            return cell ?? UITableViewCell()
        case .sentFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
            cell?.textLabel?.text = NSLocalizedString("id_sent_from", comment: "")
            cell?.detailTextLabel?.text = "\(tx.addressees.first ?? "")"
            return cell ?? UITableViewCell()
        case .id:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
            cell?.textLabel?.text = NSLocalizedString("id_transaction_id", comment: "")
            cell?.detailTextLabel?.text = "\(tx.hash)"
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.backgroundColor = UIColor.darkBlueGray
            imageView.image = UIImage(named: "copy")
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyId))
            cell?.detailTextLabel?.addGestureRecognizer(tap)
            cell?.accessoryView = imageView
            cell?.accessoryView?.backgroundColor = UIColor.darkBlueGray
            return cell ?? UITableViewCell()
        case .middleSeparator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "middleSeparator")
            return cell ?? UITableViewCell()
        case .finalSeparator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "finalSeparator")
            return cell ?? UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = fields[indexPath.row]
        if field == .finalSeparator {
            return 24
        }
        return UITableView.automaticDimension
    }
}
