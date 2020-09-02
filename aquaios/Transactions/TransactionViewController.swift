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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var tx: Transaction!
    private var fields = [TxField]()
    private var footerView: TransactionFooterCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNavigationBarBackgroundColor(.darkBlueGray)
        showCloseButton(on: .left)
        copiedButton.alpha = 0.0
        copiedButton.round(radius: 17.5)
        reload()
    }

    func configure() {
        if tx.incoming {
            titleLabel.text = NSLocalizedString("id_received", comment: "")
        } else if tx.outgoing {
            titleLabel.text = NSLocalizedString("id_sent", comment: "")
        } else {
            titleLabel.text = NSLocalizedString("id_redeposit", comment: "")
        }
        pendingLabel.isHidden = tx.blockHeight > 0
        dateLabel.text = AquaService.date(from: tx.createdAt, dateStyle: .medium, timeStyle: .medium)
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 8
        tableView.rowHeight = UITableView.automaticDimension
        footerView = Bundle.main.loadNibNamed("TransactionFooterCell", owner: self, options: nil)![0] as? TransactionFooterCell
        tableView.tableFooterView = footerView
        footerView?.configure(with: tx)
        let nib = UINib(nibName: "TransactionNoteCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionNoteCell")
    }

    func reload() {
        fields = [TxField.amount, TxField.asset]
        fields += (tx.outgoing || tx.redeposit ? [TxField.fee] : [])
        fields += [TxField.notes, TxField.middleSeparator]
        fields += (tx.outgoing ? [TxField.sentFrom] : [])
        fields += [TxField.id, TxField.finalSeparator]
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let dest = nav.topViewController as? NoteViewController {
            dest.transaction = tx
            dest.updateTransaction = { transaction in
                self.tx = transaction
                self.reload()
            }
        }
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
            cell?.selectionStyle = .none
            cell?.textLabel?.text = NSLocalizedString("id_amount", comment: "")
            cell?.detailTextLabel?.text = "\(asset.string(amount) ?? "") \(asset.ticker ?? "")"
            return cell ?? UITableViewCell()
        case .asset:
            let tag = tx.defaultAsset
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.selectionStyle = .none
            cell?.textLabel?.text = NSLocalizedString("id_asset", comment: "")
            cell?.detailTextLabel?.text = asset.name ?? tag
            return cell ?? UITableViewCell()
        case .fee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.selectionStyle = .none
            let tag = tx.networkName == Liquid.networkName ? Liquid.shared.policyAsset : "btc"
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            cell?.textLabel?.text = NSLocalizedString("id_fee", comment: "")
            cell?.detailTextLabel?.text = "\(asset.string(tx.fee ) ?? "") \(asset.ticker ?? "")"
            return cell ?? UITableViewCell()
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionNoteCell") as? TransactionNoteCell
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            cell?.titleLabel?.text = NSLocalizedString("id_notes", comment: "")
            cell?.noteLabel?.text = "\(tx.memo)"
            return cell ?? UITableViewCell()
        case .sentFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
            cell?.selectionStyle = .none
            cell?.textLabel?.text = NSLocalizedString("id_sent_from", comment: "")
            cell?.detailTextLabel?.text = "\(tx.addressees.first ?? "")"
            return cell ?? UITableViewCell()
        case .id:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
            cell?.selectionStyle = .none
            cell?.textLabel?.text = NSLocalizedString("id_transaction_id", comment: "")
            cell?.detailTextLabel?.text = "\(tx.hash)"
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.backgroundColor = UIColor.darkBlueGray
            imageView.image = UIImage(named: "copy")
            cell?.accessoryView = imageView
            cell?.accessoryView?.backgroundColor = UIColor.darkBlueGray
            return cell ?? UITableViewCell()
        case .middleSeparator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "middleSeparator")
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .finalSeparator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "finalSeparator")
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch fields[indexPath.row] {
        case .notes:
            performSegue(withIdentifier: "note", sender: nil)
        case .id:
            copiedButton.fadeInOut()
            UIPasteboard.general.string = self.tx.hash
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        default:
            break
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
