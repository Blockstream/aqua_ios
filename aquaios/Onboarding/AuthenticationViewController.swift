import Foundation

class AuthenticationViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    @IBAction func enable(_ sender: Any) {
        storeMnemonic(safe: true)
    }

    @IBAction func skip(_ sender: Any) {
        storeMnemonic(safe: false)
    }
}
