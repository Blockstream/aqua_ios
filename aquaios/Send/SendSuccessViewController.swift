import UIKit

class SendSuccessViewController: BaseViewController {

    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        doneButton.round(radius: 26.5)
        showCloseButton(on: .left)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        presentingViewController?.dismissModal(animated: true)
    }
}
