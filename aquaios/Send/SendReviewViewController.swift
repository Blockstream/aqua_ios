import UIKit
import PromiseKit

class SendReviewViewController: BaseViewController {

    @IBOutlet weak var reviewBackgroundView: UIView!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var networkFeeButton: UIButton!
    @IBOutlet weak var slidingButton: SlidingButton!

    @IBOutlet weak var feeUpdateView: UIView!
    @IBOutlet weak var feeUpdateViewAnimatedConstraint: NSLayoutConstraint!
    @IBOutlet weak var defaultFeeButton: UIButton!
    @IBOutlet weak var rushFeeButton: UIButton!

    @IBOutlet weak var addressLabelVisibilityButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    var tx: RawTransaction!

    private var feeUpdateViewHidden = true

    @IBOutlet weak var myNotesLbl: UILabel!
    @IBOutlet weak var memoField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        slidingButton.delegate = self
        slidingButton.buttonText = NSLocalizedString("id_slide_to_send", comment: "")
        slidingButton.buttonFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        slidingButton.round(radius: 26.5)

        myNotesLbl.text = NSLocalizedString("id_my_notes", comment: "")
        memoField.delegate = self
        memoField.layer.borderWidth = 3.0
        memoField.layer.borderColor = UIColor.aquaShadowBlue.cgColor
        memoField.layer.masksToBounds = true
        memoField.layer.cornerRadius = 12.0
        memoField.attributedPlaceholder =
            NSAttributedString(string: NSLocalizedString("id_only_visible_to_you", comment: ""),
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.auroMetalSaurus])

         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        configureView()
    }

    func configureView() {
        reviewBackgroundView.round(radius: 18)
        feeUpdateView.round(radius: 18)
        defaultFeeButton.round(radius: 24)
        rushFeeButton.round(radius: 24)
        defaultFeeButton.setBackgroundColor(color: .teal, for: .selected)
        rushFeeButton.setBackgroundColor(color: .teal, for: .selected)
        defaultFeeButton.isSelected = true
        rushFeeButton.isSelected = false

        // Fill transaction data
        let addressee = tx.addressees.first!
        let info = Registry.shared.info(for: addressee.assetTag ?? "btc")
        let asset = Asset(info: info, tag: addressee.assetTag)
        let amount = tx.sendAll ? NSLocalizedString("id_all", comment: "") : asset.string(addressee.satoshi)
        sendLabel.text = NSLocalizedString("id_send", comment: "")
        amountLabel.text = "\(amount ?? "") \(asset.ticker ?? "")"
        toLabel.text = NSLocalizedString("id_to", comment: "")
        addressLabel.text = addressee.address
        if asset.hasFiatRate {
            let fiat = Fiat.from(addressee.satoshi)
            fiatLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }
        if let fee = tx.fee {
            let fiat = Fiat.from(fee)
            let fiatFees = "\(Fiat.currency() ?? "") \( fiat ?? "")"
            feeLabel.text = fiatFees
            defaultFeeButton.setTitle(NSLocalizedString("id_slow", comment: ""), for: .normal)
            rushFeeButton.setTitle(NSLocalizedString("id_urgent", comment: ""), for: .normal)
        }
        networkFeeButton.setTitle(NSLocalizedString("id_network_fee", comment: ""), for: .normal)
        // Disable fee buttons for liquid
        networkFeeButton.isEnabled = asset.isBTC
    }

    func highLightFee() {
        UIView.animate(withDuration: 0.25, animations: {
            self.feeLabel.layer.backgroundColor = UIColor.teal.cgColor
        }, completion: {_ in
            UIView.animate(withDuration: 0.25) {
                self.feeLabel.layer.backgroundColor = UIColor.clear.cgColor
               }
        })
    }

    @IBAction func networkFeeButtonTapped(_ sender: Any) {
        let constant: CGFloat = feeUpdateViewHidden ? -22 : -126
        let image = feeUpdateViewHidden ? UIImage(named: "arrow_up") : UIImage(named: "arrow_down")
        UIView.animate(withDuration: 0.5) {
            self.feeUpdateViewAnimatedConstraint.constant = constant
            self.networkFeeButton.setImage(image, for: .normal)
            self.view.layoutIfNeeded()
        }
        feeUpdateViewHidden = !feeUpdateViewHidden
    }

    func updateTransaction(tx: RawTransaction) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            return Guarantee()
        }.compactMap(on: bgq) {
            return try self.sharedNetwork.createTransaction(tx)
        }.ensure {
            self.stopAnimating()
        }.done { res in
            if res.error != nil && res.error != "" {
                let alert = UIAlertController(title: NSLocalizedString("id_error", comment: ""), message: NSLocalizedString(res.error ?? "id_error", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
                self.present(alert, animated: true)
                return
            }
            self.tx = res
            if let fee = self.tx.fee {
                self.feeLabel.text = "\(Fiat.currency() ?? "") \( Fiat.from(fee) ?? "")"
            }
            self.defaultFeeButton.isSelected = !self.defaultFeeButton.isSelected
            self.rushFeeButton.isSelected = !self.rushFeeButton.isSelected
        }.catch { err in
            if let error = err as? TransactionError {
                self.showError(error)
            }
        }
    }

    func memoSet() {
        var newTx = self.tx
        newTx!.memo = memoField.text ?? ""
        updateTransaction(tx: newTx!)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func defaultFeeButtonTapped(_ sender: Any) {
        if defaultFeeButton.isSelected { return }
        var newTx = self.tx
        newTx!.feeRate = sharedNetwork.getDefaultFees()
        updateTransaction(tx: newTx!)
        highLightFee()
    }

    @IBAction func rushFeeButtonTapped(_ sender: Any) {
        if rushFeeButton.isSelected { return }
        var newTx = self.tx
        newTx!.feeRate = sharedNetwork.getFastFees()
        updateTransaction(tx: newTx!)
        highLightFee()
    }

    @IBAction func addressLabelVisibilityToggle(_ sender: Any) {
        switch addressLabel.numberOfLines {
        case 1:
            addressLabel.numberOfLines = 0
        default:
            addressLabel.numberOfLines = 1
        }
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SendSuccessViewController {
            dest.tx = sender as? Transaction
        }
    }
}

extension SendReviewViewController: SlidingButtonDelegate {

    private var sharedNetwork: NetworkSession {
        if let tag = tx.addressees.first?.assetTag, tag != "btc" {
            return Liquid.shared
        } else {
            return Bitcoin.shared
        }
    }

    func completed(slidingButton: SlidingButton) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            self.slidingButton.isHidden = true
            return Guarantee()
        }.compactMap(on: bgq) {
            return try self.sharedNetwork.sendTransaction(self.tx)
        }.ensure {
            self.stopAnimating()
        }.done { id in
            let sentTx = Transaction(hash: id, height: 0, rawTx: self.tx)
            self.performSegue(withIdentifier: "success", sender: sentTx)
        }.catch { err in
            if let error = err as? TransactionError {
                self.showError(error)
            } else {
                self.showError(err.localizedDescription)
            }
            self.slidingButton.isHidden = false
        }
    }
}

extension SendReviewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        memoSet()
        self.view.endEditing(true)
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let bottomOffset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}
