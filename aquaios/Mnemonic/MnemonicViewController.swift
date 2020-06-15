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
        populateLabels()
    }

    func populateLabels() {
        if !Mnemonic.supportsPasscodeAuthentication() {
            showError("Enable passcode in iPhone settings to continue")
            return
        }
        guard let mnemonic = try? Mnemonic.read() else {
            let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: "Access failure", preferredStyle: .alert)
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
