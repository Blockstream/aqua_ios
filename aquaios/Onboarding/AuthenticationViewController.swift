import Foundation

class AuthenticationViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func storeMnemonic(safe: Bool) {
        guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
            return showError("Invalid mnemonic")
        }
        do {
            try Mnemonic.write(mnemonic, safe: safe)
        } catch {
            return showError(error.localizedDescription)
        }
    }

    @IBAction func enable(_ sender: Any) {
        storeMnemonic(safe: true)
        self.navigationController?.topViewController?.dismissModal(animated: true)
    }

    @IBAction func skip(_ sender: Any) {
        storeMnemonic(safe: false)
        self.navigationController?.topViewController?.dismissModal(animated: true)
    }
}
