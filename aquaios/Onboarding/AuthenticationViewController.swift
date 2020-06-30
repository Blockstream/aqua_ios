import Foundation
import UIKit
import LocalAuthentication

class AuthenticationViewController: BaseViewController {

    @IBOutlet weak var enableButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var authIcon: UIImageView!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableButton.round(radius: 26.5)
        enableButton.setTitle(NSLocalizedString("id_enable", comment: ""), for: .normal)
        skipButton.setTitle(NSLocalizedString("id_skip", comment: ""), for: .normal)

        switch authType() {
        case .touchID:
            authLabel.text = NSLocalizedString("id_enable_touch_id", comment: "")
            authDescriptionLabel.text = NSLocalizedString("id_secure_your_aqua_wallet_with_a", comment: "")
            authIcon.image = UIImage(named: "touchid")
        case .faceID:
            authLabel.text = NSLocalizedString("id_enable_face_id", comment: "")
            authDescriptionLabel.text = NSLocalizedString("id_the_fastest_way_to_secure_your", comment: "")
            authIcon.image = UIImage(named: "faceid")
        default:
            authLabel.text = NSLocalizedString("id_enable_passcode", comment: "")
            authDescriptionLabel.text = NSLocalizedString("id_a_quick_and_easy_way_to_secure", comment: "")
            authIcon.image = UIImage(named: "passcode")
        }
    }

    func storeMnemonic(safe: Bool) {
        if !Mnemonic.supportsPasscodeAuthentication() {
            showError(NSLocalizedString("id_enable_passcode_in_ios_settings", comment: ""))
            return
        }
        guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
            return showError(NSLocalizedString("id_invalid_mnemonic", comment: ""))
        }
        do {
            try Mnemonic.write(mnemonic, safe: safe)
            self.navigationController?.topViewController?.dismissModal(animated: true)
        } catch {
            if let err = error as? KeychainError {
                showError(err.localizedDescription)
            } else {
                showError(error.localizedDescription)
            }
        }
    }

    func authType() -> LABiometryType {
        let context = LAContext()

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return LABiometryType.none
        }
        return context.biometryType
    }

    @IBAction func enable(_ sender: Any) {
        storeMnemonic(safe: true)
    }

    @IBAction func skip(_ sender: Any) {
        storeMnemonic(safe: false)
    }
}
