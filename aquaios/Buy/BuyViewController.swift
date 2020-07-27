import UIKit

class BuyViewController: BaseViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionStackView: UIStackView!
    @IBOutlet weak var actionStackBackgroundView: UIView!
    @IBOutlet weak var btcButton: UIButton!
    @IBOutlet weak var lbtcButton: UIButton!
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyIconView: UIView!
    private var wyreService: WyreService!

    override func viewDidLoad() {
        super.viewDidLoad()
        wyreService = WyreService(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actionStackBackgroundView.round(radius: 21, borderWidth: 2, borderColor: .tiffanyBlue)
        configurePreLogin()
        if hasWallet {
            buyView.isHidden = true
            btcButton.isHidden = false
            lbtcButton.isHidden = false
            infoLabel.isHidden = false
            infoLabel.text = "Checking availability..."
            wyreService.getWidget()
        } else {
            btcButton.isHidden = true
            lbtcButton.isHidden = true
            infoLabel.isHidden = true
        }
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        let buyBtc = sender.titleLabel?.text == "Buy bitcoin"
        performSegue(withIdentifier: "buy_wyre", sender: buyBtc)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? WyreWidgetViewController {
            dest.buyBtc = sender as? Bool
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
        if !(widget.hasRestrictions ?? true) {
            DispatchQueue.main.async {
                self.infoLabel.text = "Buy with Debit Card"
                self.actionStackView.isHidden = false
                self.actionStackBackgroundView.isHidden = false
            }
        }
    }

    func requestFailed(with error: Error) {
    }
}
