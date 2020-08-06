import UIKit
import LocalAuthentication

class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeLabel: UILabel!

    var labels = [NSLocalizedString("id_support", comment: ""),
                  NSLocalizedString("id_view_my_recovery_phrase", comment: "")]

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.removeWalletAlert))
        removeLabel.addGestureRecognizer(tapGestureRecognizer)
        removeLabel.isUserInteractionEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func configure() {
        if hasWallet {
            labels.append(authLabel())
            configureTableView()
            hideCreateWalletView()
            self.tableView.isHidden = false
            self.removeLabel.isHidden = false
            navigationItem.title = NSLocalizedString("id_profile", comment: "")
        } else {
            self.tableView.isHidden = true
            self.removeLabel.isHidden = true
            showCreateWalletView(delegate: self)
        }
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }

    func authType() -> LABiometryType {
        let context = LAContext()

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return LABiometryType.none
        }
        return context.biometryType
    }

    func authLabel() -> String {
        switch authType() {
        case .faceID:
            return NSLocalizedString("id_face_id", comment: "")
        case .touchID:
            return NSLocalizedString("id_touch_id", comment: "")
        default:
            return NSLocalizedString("id_passcode", comment: "")
        }
    }

    @objc func removeWalletAlert(_ sender: Any?) {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: NSLocalizedString("id_doublecheck_that_you_have_a", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .destructive) { _ in
            self.removeWallet()
        })
        self.present(alert, animated: true, completion: nil)
    }

    func removeWallet() {
        UserDefaults.standard.set(false, forKey: Constants.Keys.hasBackedUp)
        UserDefaults.standard.set(false, forKey: Constants.Keys.hasShownBackup)
        UserDefaults.standard.set([String](), forKey: Constants.Keys.pinnedAssets)
        try? Mnemonic.delete()
        exit(0)
    }

    func enableSafeMnemonic() {
        guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
            return self.showError(NSLocalizedString("id_invalid_mnemonic", comment: ""))
        }
        try? Mnemonic.delete()
        try? Mnemonic.write(mnemonic, safe: true)
        let alert = UIAlertController(title: NSLocalizedString("id_success", comment: ""), message: String(format: NSLocalizedString("id_login_with__enabled", comment: ""), authLabel()), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .default) { _ in })
        self.present(alert, animated: true, completion: nil)
    }

    func disableSafeMnemonic() {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: String(format: NSLocalizedString("id_do_you_want_to_disable_", comment: ""), authLabel()), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: String(format: NSLocalizedString("id_disable_", comment: ""), authLabel()), style: .destructive) { _ in
            guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
                return self.showError(NSLocalizedString("id_invalid_mnemonic", comment: ""))
            }
            try? Mnemonic.delete()
            try? Mnemonic.write(mnemonic, safe: false)
        })
        self.present(alert, animated: true, completion: nil)
    }

    @objc func switchStateDidChange(_ sender: UISwitch) {
        if sender.isOn {
            enableSafeMnemonic()
        } else {
            disableSafeMnemonic()
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = labels[indexPath.row]
        if indexPath.row == 2 {
            let switcher = UISwitch()
            switcher.isOn = Mnemonic.protected()
            switcher.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
            cell?.accessoryView = switcher
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let url = URL(string: "https://blockstream.zendesk.com/hc/en-us") {
              UIApplication.shared.open(url)
            }
        case 1:
            // view mnemonic
            performSegue(withIdentifier: "mnemonic", sender: nil)
        case 2:
            // device authorization
            break
        default:
            return
        }
    }
}

extension SettingsViewController: CreateWalletDelegate {
    func didTapCreate() {
        showOnboarding(with: self)
    }

    func didTapRestore() {
        showRestore(with: self)
    }

}

extension SettingsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        configure()
    }
}
