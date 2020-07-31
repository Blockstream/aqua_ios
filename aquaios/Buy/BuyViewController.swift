import UIKit
import PromiseKit

class BuyViewController: BaseViewController {

    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyIconView: UIView!
    @IBOutlet weak var buyBtcView: UIView! // !!!
    @IBOutlet weak var buyLbtcView: UIView! //
    @IBOutlet weak var buyBtcButton: UIButton!
    @IBOutlet weak var buyLbtcButton: UIButton!
    @IBOutlet weak var comingSoonLabel: UILabel!
    private var wyreService: WyreService!
    private var wyreAllowed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        wyreService = WyreService(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buyBtcButton.round(radius: 16)
        buyLbtcButton.round(radius: 16)
        configurePreLogin()
        if hasWallet {
            buyView.isHidden = true
            buyBtcView.isHidden = false
            buyLbtcView.isHidden = false
            comingSoonLabel.isHidden = false
            wyreService.getWidget()
        } else {
            buyBtcView.isHidden = true
            buyLbtcView.isHidden = true
            comingSoonLabel.isHidden = true
        }
    }

    func prepareBuy(isBtc: Bool) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            return Guarantee()
        }.compactMap(on: bgq) {
            self.wyreService.getWidget()
        }.ensure {
            self.stopAnimating()
        }.done {  _ in
            if self.wyreAllowed {
                self.performSegue(withIdentifier: "buy_wyre", sender: isBtc)
            } else {
                self.showAlert(title: "Error", message: "Service not available in your country")
            }
        }
    }

    @IBAction func buyBtcTapped(_ sender: Any) {
        prepareBuy(isBtc: true)
    }
    @IBAction func buyLbtcTapped(_ sender: Any) {
        prepareBuy(isBtc: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? WyreWidgetViewController {
            dest.buyBtc = sender as? Bool
        }
        if let dest = segue.destination as? CreateWalletAlertController {
            dest.delegateVC = self
        }
    }

    func configurePreLogin() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createOrRestore))
        buyView.addGestureRecognizer(tapGestureRecognizer)
        buyView.isUserInteractionEnabled = true
        buyView.round(radius: 24)
        buyIconView.round(radius: 24)
    }

    @objc func createOrRestore(_ sender: Any?) {
        performSegue(withIdentifier: "create_wallet_alert", sender: nil)
    }
}

extension BuyViewController: WyreServiceDelegate {
    func widgetRetrieved(with widget: WyreWidget) {
        self.wyreAllowed = !(widget.hasRestrictions ?? true)
    }

    func requestFailed(with error: Error) {
    }
}
