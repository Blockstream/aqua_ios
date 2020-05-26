import UIKit
import PromiseKit

class SendReviewViewController: BaseViewController {

    @IBOutlet weak var reviewBackgroundView: UIView!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var networkFeeButton: UIButton!
    @IBOutlet weak var slidingButton: SlidingButton!

    @IBOutlet weak var feeUpdateView: UIView!
    @IBOutlet weak var feeUpdateViewAnimatedConstraint: NSLayoutConstraint!
    @IBOutlet weak var defaultFeeButton: UIButton!
    @IBOutlet weak var rushFeeButton: UIButton!

    var tx: RawTransaction!

    private var feeUpdateViewHidden = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        configureView()
    }

    func configureView() {
        slidingButton.delegate = self
        reviewBackgroundView.round(radius: 18)
        feeUpdateView.round(radius: 18)
        defaultFeeButton.round(radius: 24)
        rushFeeButton.round(radius: 24)

        // Fill transaction data
        let addressee = tx.addressees.first!
        let info = Registry.shared.info(for: addressee.assetTag ?? "btc")
        let asset = Asset(info: info, tag: addressee.assetTag)
        let amount = tx.sendAll ? "All" : asset.string(addressee.satoshi)
        amountLabel.text = "\(amount ?? "") \(asset.ticker ?? "")"
        addressLabel.text = addressee.address
        if asset.isBTC || asset.isLBTC {
            let fiat = Fiat.from(addressee.satoshi)
            fiatLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }
        if let fee = tx.fee {
            let fiat = Fiat.from(fee)
            feeLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }
    }

    override func viewDidLayoutSubviews() {
        slidingButton.round(radius: 26.5)
        slidingButton.buttonFont = UIFont.systemFont(ofSize: 16, weight: .medium)
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

    @IBAction func defaultFeeButtonTapped(_ sender: Any) {
    }

    @IBAction func rushFeeButtonTapped(_ sender: Any) {
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
        }.done { _ in
            self.performSegue(withIdentifier: "success", sender: nil)
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
