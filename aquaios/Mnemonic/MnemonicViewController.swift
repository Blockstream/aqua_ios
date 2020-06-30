import UIKit

class MnemonicViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var mnemonicBackgroundView: UIView!
    @IBOutlet var mnemonicLabels: [UILabel]!
    @IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        mnemonicBackgroundView.round(radius: 18)
        confirmButton.round(radius: 24)
        titleLabel.text = NSLocalizedString("id_write_down_your_recovery_phrase", comment: "")
        messageLabel.text = NSLocalizedString("id_the_12word_recovery_phrase_is", comment: "")
        populateLabels()
        confirmButton.setTitle("id_confirm_backup", for: .normal)
    }

    func populateLabels() {
        if !Mnemonic.supportsPasscodeAuthentication() {
            showError(NSLocalizedString("id_enable_passcode_in_ios_settings", comment: ""))
            return
        }
        guard let mnemonic = try? Mnemonic.read() else {
            let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: NSLocalizedString("id_authentication_failed", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("id_back", comment: ""), style: .cancel) { _ in
                self.dismissModal(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
            return
        }
        let words = mnemonic.split(separator: " ")
        if words.count > 0 && words.count == mnemonicLabels.count {
            for(label, word) in zip(mnemonicLabels, words) {
                label.text = String(word)
            }
        }
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "confirm", sender: nil)
    }
}
