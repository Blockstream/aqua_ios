import Foundation
import UIKit

class RestoreViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstMessageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = NSLocalizedString("id_get_your_aqua_recovery_phrase", comment: "")
        firstMessageLabel.text = NSLocalizedString("id_you_can_restore_your_wallet", comment: "")
        startButton.setTitle(NSLocalizedString("id_start", comment: ""), for: .normal)
        startButton.round(radius: 24)
        navigationController?.setNavigationBarHidden(false, animated: true)
        showCloseButton(on: .left)
    }
}
