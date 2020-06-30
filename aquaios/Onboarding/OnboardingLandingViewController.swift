import UIKit

class OnboardingLandingViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextButton.round(radius: 0.5 * nextButton.bounds.width)
        titleLabel.text = NSLocalizedString("id_digital_finance_at_its_most", comment: "")
        messageLabel.text = NSLocalizedString("id_manage_your_bitcoin_and_liquid", comment: "")
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "tos", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TermsOfServiceViewController {
            dest.presentationController?.delegate = self
        }
    }
}

extension OnboardingLandingViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss(animated: true, completion: nil)
    }
}
