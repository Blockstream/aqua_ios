import UIKit

class BackupCompleteViewController: BaseViewController {

    @IBOutlet weak var animationPlaceholder: UIImageView!
    @IBOutlet weak var retryStackView: UIStackView!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var failedImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    var success: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        configure()
    }

    func configure() {
        quitButton.round(radius: 24)
        retryButton.round(radius: 24)
        doneButton.round(radius: 24)
        quitButton.setTitle(NSLocalizedString("id_quit", comment: ""), for: .normal)
        retryButton.setTitle(NSLocalizedString("id_retry", comment: ""), for: .normal)
        doneButton.setTitle(NSLocalizedString("id_done", comment: ""), for: .normal)

        retryStackView.isHidden = success
        failedImageView.isHidden = success

        animationPlaceholder.isHidden = !success
        doneButton.isHidden = !success
        messageLabel.isHidden = !success

        titleLabel.text = success ? NSLocalizedString("id_congratulations_youve_just_made", comment: "") : NSLocalizedString("id_oops_make_sure_you_have_written", comment: "")
        messageLabel.text = NSLocalizedString("id_remember_keep_your_recovery", comment: "")
    }

    @IBAction func retryButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func quitButtonTapped(_ sender: Any) {
        presentingViewController?.presentingViewController?.dismissModal(animated: true)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: Constants.Keys.hasBackedUp)
        presentingViewController?.presentingViewController?.dismissModal(animated: true)
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
