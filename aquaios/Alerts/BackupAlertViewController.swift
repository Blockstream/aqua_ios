import UIKit

class BackupAlertViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        laterButton.round(radius: 24)
        backupButton.round(radius: 24)
        dismissButton.round(radius: dismissButton.frame.height / 2,
                            borderWidth: 1, borderColor: .white)
        backgroundView.round(radius: 18)
        laterButton.setTitle(NSLocalizedString("id_maybe_later", comment: ""), for: .normal)
        backupButton.setTitle(NSLocalizedString("id_back_up_now", comment: ""), for: .normal)
        configureLabels()
    }

    func configureLabels() {
        titleLabel.text = "🤓" + NSLocalizedString("id_safety_first", comment: "")
        firstLabel.text = "\u{2022} " + NSLocalizedString("id_its_important_to_back_up_your", comment: "")
        secondLabel.text = "\u{2022} " + NSLocalizedString("id_without_your_recovery_phrase", comment: "")
        let attributedString = NSMutableAttributedString(string: "\u{2022} " + NSLocalizedString("id_most_users_back_up_their_wallet", comment: ""), attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.paleLilac
        ])
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.topaz
        ], range: NSRange(location: 2, length: 3))
        thirdLabel.attributedText = attributedString
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismissModal(animated: true)
    }

    @IBAction func backupNowTapped(_ sender: Any) {
        performSegue(withIdentifier: "backup_alert", sender: nil)
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
