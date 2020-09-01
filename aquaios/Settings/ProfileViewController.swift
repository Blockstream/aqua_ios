import Foundation
import UIKit

class ProfileViewController: BaseViewController {

    enum Voices: CaseIterable {
        case SupportFeedback
        case RecoveryPhrase
        case Settings
        case TermsPrivacy
        case AboutUs
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 54

        let headerView = Bundle.main.loadNibNamed("ProfileHeaderCell", owner: self, options: nil)![0] as? ProfileHeaderCell
        headerView?.configure()
        tableView.tableHeaderView = headerView

        let cellNib = UINib(nibName: "SettingCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SettingCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "              " + NSLocalizedString("id_profile", comment: "")
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Voices.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell
        cell?.accessoryType = .disclosureIndicator
        cell?.selectionStyle = .none
        switch Voices.allCases[indexPath.row] {
        case .AboutUs:
            cell?.icon.image = UIImage(named: "about")
            cell?.title.text = NSLocalizedString("id_about_us", comment: "")
        case .RecoveryPhrase:
            cell?.icon.image = UIImage(named: "mnemonic")
            cell?.title.text = NSLocalizedString("id_view_my_recovery_phrase", comment: "")
        case .Settings:
            cell?.icon.image = UIImage(named: "settings")
            cell?.title.text = NSLocalizedString("id_settings", comment: "")
        case .SupportFeedback:
            cell?.icon.image = UIImage(named: "support")
            cell?.title.text = NSLocalizedString("id_support_and_feedback", comment: "")
        case .TermsPrivacy:
            cell?.icon.image = UIImage(named: "terms")
            cell?.title.text = NSLocalizedString("id_terms_and_privacy", comment: "")
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Voices.allCases[indexPath.row] {
        case .AboutUs:
            performSegue(withIdentifier: "aboutus", sender: nil)
        case .RecoveryPhrase:
            performSegue(withIdentifier: "mnemonic", sender: nil)
        case .Settings:
            performSegue(withIdentifier: "settings", sender: nil)
        case .SupportFeedback:
            performSegue(withIdentifier: "support", sender: nil)
            /*if let url = URL(string: "https://blockstream.zendesk.com/hc/en-us") {
              UIApplication.shared.open(url)
            }*/
        case .TermsPrivacy:
            if let url = URL(string: "https://blockstream.zendesk.com/hc/en-us") {
              UIApplication.shared.open(url)
            }
        }
    }
}

extension ProfileViewController: CreateWalletDelegate {
    func didTapCreate() {
        showOnboarding(with: self)
    }

    func didTapRestore() {
        showRestore(with: self)
    }

}

extension ProfileViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    }
}
