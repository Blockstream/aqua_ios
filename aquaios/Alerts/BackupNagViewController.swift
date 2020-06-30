import UIKit

class BackupNagViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueButton.round(radius: 24, borderWidth: 2, borderColor: .topaz)
        backgroundView.round(radius: 18)
        titleLabel.text = "🤓 " + NSLocalizedString("id_its_time_to_back_up_your_wallet", comment: "")
        messageLabel.text = NSLocalizedString("id_if_you_lose_or_break_your", comment: "")
        continueButton.setTitle(NSLocalizedString("id_continue", comment: ""), for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismissModal(animated: true)
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "backup_nag", sender: nil)
    }
}
