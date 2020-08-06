import UIKit

class SendSuccessViewController: BaseViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNavigationBarBackgroundColor(.lighterBlueGray)
        doneButton.round(radius: 26.5)
        showCloseButton(on: .left)
        doneButton.setTitle(NSLocalizedString("id_done", comment: ""), for: .normal)
        successLabel.text = NSLocalizedString("id_payment_sent", comment: "")
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        presentingViewController?.dismissModal(animated: true)
    }
}
