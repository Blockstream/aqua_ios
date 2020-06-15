import Foundation
import UIKit
import LocalAuthentication

class AuthenticationViewController: BaseViewController {

    @IBOutlet weak var enableButton: UIButton!
    @IBOutlet weak var authIcon: UIImageView!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableButton.round(radius: 26.5)
        switch authType() {
        case .touchID:
            authLabel.text = "Enable Touch ID"
            authDescriptionLabel.text = "Secure your aqua wallet with a simple thumb press"
            authIcon.image = UIImage(named: "touchid")
        case .faceID:
            authLabel.text = "Enable Face ID"
            authDescriptionLabel.text = "The fastest wasy to secure your AQUA wallet"
            authIcon.image = UIImage(named: "faceid")
        default:
            authLabel.text = "Enable Passcode"
            authDescriptionLabel.text = "A quick and easy way to secure your AQUA wallet"
            authIcon.image = UIImage(named: "passcode")
        }
    }

    func storeMnemonic(safe: Bool) {
        if !Mnemonic.supportsPasscodeAuthentication() {
            showError("Enable passcode in iPhone settings to continue")
            return
        }
        guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
            return showError("Invalid mnemonic")
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
