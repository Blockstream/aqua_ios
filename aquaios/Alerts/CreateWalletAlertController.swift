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
        titleLabel.text = NSLocalizedString("id_please_create_wallet", comment: "")
        messageLabel.text = NSLocalizedString("id_you_will_need_to_setup", comment: "")
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
}

extension CreateWalletAlertController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissModal(animated: true)
    }
}
