import UIKit
import LocalAuthentication

class SettingsViewController: BaseViewController {

    enum Voices: CaseIterable {
        case auth
        case currency
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = NSLocalizedString("id_settings", comment: "")
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        let footerView = Bundle.main.loadNibNamed("SettingsFooterCell", owner: self, options: nil)![0] as? SettingsFooterCell
        footerView?.delegate = self
        footerView?.configure()
        tableView.tableFooterView = footerView
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

    func enableSafeMnemonic() {
        guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
            return self.showError(NSLocalizedString("id_invalid_recovery_phrase", comment: ""))
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
                return self.showError(NSLocalizedString("id_invalid_recovery_phrase", comment: ""))
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
        return Voices.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        switch Voices.allCases[indexPath.row] {
        case .auth:
            let switcher = UISwitch()
            switcher.isOn = Mnemonic.protected()
            switcher.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
            cell?.accessoryView = switcher
            cell?.textLabel?.text = authLabel()
        case .currency:
            cell?.textLabel?.text = NSLocalizedString("id_reference_exchange_rate", comment: "")
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 20))
            label.textColor = .gray
            label.text = "USD"
            label.textAlignment = .right
            cell?.accessoryView = label
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Voices.allCases[indexPath.row] {
        case .auth:
            break
        case .currency:
            break
        }
    }
}

extension SettingsViewController: SettingsFooterActions {

    func remove() {
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
        UserDefaults.standard.set(false, forKey: Constants.Keys.isWalletRestored)
        UserDefaults.standard.set([String](), forKey: Constants.Keys.pinnedAssets)
        try? Mnemonic.delete()
        exit(0)
    }
}
