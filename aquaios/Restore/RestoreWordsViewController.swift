import Foundation
import UIKit
import PromiseKit

class RestoreWordsViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstMessageLabel: UILabel!
    @IBOutlet var mnemonicTextFields: [UITextField]!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        titleLabel.text = NSLocalizedString("id_restore_an_aqua_wallet", comment: "")
        firstMessageLabel.text = NSLocalizedString("id_enter_recovery_phrase", comment: "")
        continueButton.round(radius: 24)
        continueButton.setTitle(NSLocalizedString("id_restore", comment: ""), for: .normal)
        setupTextFields()
    }

    @IBAction func continueTapped(_ sender: Any) {
        var mnemonic = String()
        for word in mnemonicTextFields {
            mnemonic.append(word.text ?? "")
            if mnemonicTextFields.firstIndex(of: word)! < 11 { mnemonic.append(" ") }
        }
        self.register(mnemonic: mnemonic)
    }

    func register(mnemonic: String) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating(message: NSLocalizedString("id_restoring_your_wallet", comment: ""))
            return Guarantee()
        }.map(on: bgq) {
            try Liquid.shared.disconnect()
            try Bitcoin.shared.disconnect()
        }.map(on: bgq) {
            try Liquid.shared.connect()
            try Bitcoin.shared.connect()
        }.map(on: bgq) {
            try Liquid.shared.login(mnemonic)
            try Bitcoin.shared.login(mnemonic)
        }.compactMap(on: bgq) {
            try? Registry.shared.refresh(Liquid.shared.session!)
        }.ensure {
            self.stopAnimating()
        }.done { _ in
            self.performSegue(withIdentifier: "next", sender: nil)
        }.catch { error in
            let message: String
            if let err = error as? GaError, err != GaError.GenericError {
                message = NSLocalizedString("id_connection_failed", comment: "")
            } else {
                message = NSLocalizedString("id_login_failed", comment: "")
            }
            self.showError(message)
        }
    }

    func setupTextFields() {
        for word in mnemonicTextFields {
            word.autocapitalizationType = .none
            word.autocorrectionType = .no
        }
    }

    @objc func dismissKeyboard() {
    view.endEditing(true)
    }

}
