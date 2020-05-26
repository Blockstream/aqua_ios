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
