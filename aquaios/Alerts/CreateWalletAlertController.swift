import UIKit

class CreateWalletAlertController: UIViewController {

    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var delegateVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createButton.round(radius: 24)
        restoreButton.round(radius: 24)
        backgroundView.round(radius: 18)
        createButton.setTitle(NSLocalizedString("id_create", comment: ""), for: .normal)
        restoreButton.setTitle(NSLocalizedString("id_restore", comment: ""), for: .normal)
        titleLabel.text = NSLocalizedString("id_please_create_a_wallet_first", comment: "")
        messageLabel.text = NSLocalizedString("id_youll_need_to_set_up_a_wallet", comment: "")
        if hasWallet {
            dismissModal(animated: true)
            delegateVC?.viewWillAppear(true)
        }
    }

    @IBAction func restoreButtonTapped(_ sender: Any) {
        showRestore(with: self)
    }

    @IBAction func createButtonTapped(_ sender: Any) {
        showOnboarding(with: self)
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismissModal(animated: true)
    }
}

extension CreateWalletAlertController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissModal(animated: true)
    }
}
