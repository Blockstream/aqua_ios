import UIKit

class MnemonicViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var mnemonicBackgroundView: UIView!
    @IBOutlet var mnemonicLabels: [UILabel]!
    @IBOutlet weak var confirmButton: UIButton!
    private var mnemonic: [Substring] {
        get {
            if let mnemonic = UserDefaults.standard.object(forKey: Constants.Keys.mnemonic) as? String {
                return mnemonic.split(separator: " ")
            }
            return []
        }
    }

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
        if mnemonic.count > 0 && mnemonic.count == mnemonicLabels.count {
            for(label, word) in zip(mnemonicLabels, mnemonic) {
                label.text = String(word)
            }
        }
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "confirm", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
