import UIKit

class SendSuccessViewController: BaseViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copiedButton: UIButton!

    var tx: Transaction!
    private var fields = [TxField.amount, TxField.asset, TxField.fee, TxField.middleSeparator, TxField.sentFrom, TxField.id]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNavigationBarBackgroundColor(.darkBlueGray)
        view.backgroundColor = .darkBlueGray
        copiedButton.alpha = 0.0
        copiedButton.round(radius: 17.5)
        doneButton.round(radius: 26.5)
        showCloseButton(on: .left)
        doneButton.setTitle(NSLocalizedString("id_done", comment: ""), for: .normal)
        successLabel.text = NSLocalizedString("id_payment_sent", comment: "")
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 8
        tableView.rowHeight = UITableView.automaticDimension
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        presentingViewController?.dismissModal(animated: true)
    }
}

extension SendSuccessViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch fields[indexPath.row] {
        case .amount:
            let tag = tx.defaultAsset
            let amount = tx.satoshi[tag] ?? 0
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            cell?.textLabel?.text = NSLocalizedString("id_amount", comment: "")
            cell?.detailTextLabel?.text = "\(asset.string(amount) ?? "") \(asset.ticker ?? "")"
            return cell ?? UITableViewCell()
        case .asset:
            let tag = tx.defaultAsset
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            cell?.textLabel?.text = NSLocalizedString("id_asset", comment: "")
            cell?.detailTextLabel?.text = asset.name ?? tag
            return cell ?? UITableViewCell()
        case .fee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell")
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            let tag = tx.networkName == Liquid.networkName ? Liquid.shared.policyAsset : "btc"
            let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
            cell?.textLabel?.text = NSLocalizedString("id_fee", comment: "")
            cell?.detailTextLabel?.text = "\(asset.string(tx.fee ) ?? "") \(asset.ticker ?? "")"
            return cell ?? UITableViewCell()
        case .notes:
            return UITableViewCell()
        case .sentFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            cell?.textLabel?.text = NSLocalizedString("id_sent_from", comment: "")
            cell?.detailTextLabel?.text = "\(tx.addressees.first ?? "")"
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = UIImage(named: "copy")
            cell?.accessoryView = imageView
            return cell ?? UITableViewCell()
        case .id:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            cell?.textLabel?.text = NSLocalizedString("id_transaction_id", comment: "")
            cell?.detailTextLabel?.text = "\(tx.hash)"
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = UIImage(named: "copy")
            cell?.accessoryView = imageView
            return cell ?? UITableViewCell()
        case .middleSeparator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "middleSeparator")
            cell?.selectionStyle = .none
            cell?.backgroundColor = .darkBlueGray
            return cell ?? UITableViewCell()
        case .finalSeparator:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = fields[indexPath.row]
        if field == .finalSeparator {
            return 24
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch fields[indexPath.row] {
        case .id:
            copiedButton.fadeInOut()
            UIPasteboard.general.string = self.tx.hash
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .sentFrom:
            copiedButton.fadeInOut()
            UIPasteboard.general.string = self.tx.addressees.first
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        default:
            break
        }
    }
}
