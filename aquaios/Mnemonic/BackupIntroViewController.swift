import UIKit

class BackupIntroViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstMessageLabel: UILabel!
    @IBOutlet weak var secondMessageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startButton.round(radius: 24)
        navigationController?.setNavigationBarHidden(false, animated: true)
        showCloseButton(on: .left)
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "mnemonic", sender: nil)
    }
}
