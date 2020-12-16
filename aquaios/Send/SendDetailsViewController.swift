import UIKit
import PromiseKit

class SendDetailsViewController: BaseViewController {

    @IBOutlet var padKeys: [UIButton]!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var assetView: AssetView!
    @IBOutlet weak var amountBackgroundView: UIView!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amounTextField: UITextField!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var tickerButton: UIButton!
    @IBOutlet weak var sendAllButton: UIButton!
    @IBOutlet weak var dotButton: UIButton!

    var addressee: Addressee?
    private var amount: String = ""
    private var asset: Asset?
    private var sendAll = false
    private var showFiat = false

    private var balance: UInt64 {
        if let tag = addressee?.assetTag, tag != "btc" {
            return Liquid.shared.balance?[tag] ?? 0
        } else {
            return Bitcoin.shared.balance?["btc"] ?? 0
        }
    }

    private var sharedNetwork: NetworkSession {
        if let tag = addressee?.assetTag, tag != "btc" {
            return Liquid.shared
        } else {
            return Bitcoin.shared
        }
    }

    private var decimal: String {
        return NSLocale.current.decimalSeparator ?? "."
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        deleteButton.addTarget(self, action: #selector(click(sender:)), for: .touchUpInside)
        for button in padKeys.enumerated() {
            button.element.addTarget(self, action: #selector(click(sender:)), for: .touchUpInside)
        }
        configureView()
        reload()
    }

    func configureView() {
        let icon = Registry.shared.image(for: addressee?.assetTag ?? "btc")
        let info = Registry.shared.info(for: addressee?.assetTag ?? "btc")
        asset = Asset(sats: balance, icon: icon, info: info, tag: addressee?.assetTag)
        if let satoshi = addressee?.satoshi, satoshi > 0 {
            amount = asset?.string(satoshi) ?? ""
            reload()
        }
        assetView.configure(with: asset!, bgColor: .aquaShadowBlue, radius: 18)
        amountBackgroundView.round(radius: 18)
        // setup amount textfield
        amounTextField.inputView = UIView()
        amounTextField.inputAccessoryView = UIView()
        amounTextField.tintColor = .topaz
        amounTextField.becomeFirstResponder()
        // setup buttons and labels
        continueButton.round(radius: 26.5)
        amountTitleLabel.text = NSLocalizedString("id_amount", comment: "")
        tickerButton.setTitle(asset?.info?.ticker ?? "", for: .normal)
        sendAllButton.setTitle(NSLocalizedString("id_max", comment: ""), for: .normal)
        continueButton.setTitle(NSLocalizedString("id_continue", comment: ""), for: .normal)
        tickerButton.isEnabled = asset?.isBTC ?? false || asset?.isLBTC ?? false
        dotButton.setTitle(decimal, for: .normal)
    }

    @IBAction func maxButtonTapped(_ sender: Any) {
        self.sendAll = !self.sendAll
        self.amounTextField.isEnabled = !self.amounTextField.isEnabled
        if !self.sendAll { self.amounTextField.becomeFirstResponder() }
        sendAllButton.isSelected = self.sendAll
        if !sendAll {
            amount = ""
        } else if !showFiat {
            amount = self.sendAll ? asset?.string() ?? "" : ""
        } else {
            amount = Fiat.from(asset?.sats ?? 0) ?? ""
        }
        reload()
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        addressee?.satoshi = showFiat ? Fiat.to(amount) ?? 0 : asset?.satoshi(amount) ?? 0
        guard let addressee = self.addressee, addressee.satoshi > 0 else {
            return
        }
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            return Guarantee()
        }.compactMap(on: bgq) {
            let tx = try self.sharedNetwork.createTransaction(addressee, max: self.sendAll)
            if let error = tx.error, !error.isEmpty {
                throw TransactionError.generic(error)
            }
            return tx
        }.ensure {
            self.stopAnimating()
        }.done { res in
            self.performSegue(withIdentifier: "send_review", sender: res)
        }.catch { err in
            if let error = err as? TransactionError {
                self.showError(error)
            }
        }
    }

    func reload() {
        fiatLabel.isHidden = amount.isEmpty
        continueButton.isHidden = amount.isEmpty
        amounTextField.text = amount
        guard let asset = asset, asset.hasFiatRate else {
            return
        }
        if amount.isEmpty {
            return
        }
        if !showFiat {
            let satoshi = asset.satoshi(amount) ?? 0
            let fiat = Fiat.from(satoshi)
            fiatLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        } else {
            let satoshi = Fiat.to(amount)
            let value = sendAll ? asset.string() : asset.string(satoshi ?? 0)
            fiatLabel.text = "\(asset.info?.ticker ?? "") \( value ?? "")"
        }
    }

    @objc func click(sender: UIButton) {
        if sender == deleteButton {
            if amount.count > 0 {
                amount.removeLast()
            }
        } else {
            if let text = sender.titleLabel?.text {
                amount += text
            }
        }
        reload()
    }

    @IBAction func dotClick(_ sender: UIButton) {
        if amount.contains(decimal) {
            return
        }
        if amount.count == 0 {
            amount += "0"
        }
        if let text = sender.titleLabel?.text {
            amount += text
        }
        reload()
    }

    @IBAction func tickerClick(_ sender: Any) {
        // skip conversion in case fiat rate is not available
        guard Fiat.rate() != nil else {
            let alert = UIAlertController(title: NSLocalizedString("id_error", comment: ""), message: NSLocalizedString("Conversion not available", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
            self.present(alert, animated: true)
            return
        }
        showFiat = !showFiat
        tickerButton.setTitle(showFiat ? Fiat.currency() : asset?.info?.ticker ?? "", for: .normal)
        if sendAll {
            if !showFiat {
                amount = self.sendAll ? asset?.string() ?? "" : ""
            } else {
                amount = Fiat.from(asset?.sats ?? 0) ?? ""
            }
        }
        reload()
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SendReviewViewController {
            dest.tx = sender as? RawTransaction
        }
    }
}
