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
        configureLabels()
    }

    func configureLabels() {
        firstLabel.text = "\u{2022} It's important to backup your wallet by writing down your recovery phrase"
        secondLabel.text = "\u{2022} Without your recovery phrase, there is no way to recover your assets if you lose or break your device"
        let attributedString = NSMutableAttributedString(string: "\u{2022} 80% of users back up their wallet on first-time use!\n", attributes: [
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
