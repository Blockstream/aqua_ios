import UIKit
import PromiseKit

class BuyViewController: BaseViewController {

    @IBOutlet weak var noWalletView: UIView!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerBuyView: UIView!
    @IBOutlet weak var containerAvailableView: UIView!
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyIconView: UIView!
    @IBOutlet weak var buyBitcoinLabel: UILabel!
    @IBOutlet weak var buyDirectlyLabel: UILabel!
    @IBOutlet weak var buySupportedLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("id_exchange", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.paleLilac]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        segmentedControl.setTitle(NSLocalizedString("id_buy", comment: ""), forSegmentAt: 0)
        segmentedControl.setTitle(NSLocalizedString("id_available_on", comment: ""), forSegmentAt: 1)
        buyBitcoinLabel.text = NSLocalizedString("id_buy_bitcoin", comment: "")
        buyDirectlyLabel.text = NSLocalizedString("id_directly_in_the_app", comment: "")
        buySupportedLabel.text = NSLocalizedString("id_20_countries_supportedaquaios/Alerts/Alerts.storyboard", comment: "")
        configurePreLogin()
        noWalletView.isHidden = hasWallet
        walletView.isHidden = !hasWallet
    }

    @IBAction func selection(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            containerBuyView.isHidden = false
            containerAvailableView.isHidden = true
        case 1:
            containerBuyView.isHidden = true
            containerAvailableView.isHidden = false
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CreateWalletAlertController {
            dest.delegateVC = self
        }
    }

    func configurePreLogin() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createOrRestore))
        buyView.addGestureRecognizer(tapGestureRecognizer)
        buyView.isUserInteractionEnabled = true
        buyView.round(radius: 24)
    }

    @objc func createOrRestore(_ sender: Any?) {
        performSegue(withIdentifier: "create_wallet_alert", sender: nil)
    }
}
