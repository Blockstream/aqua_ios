import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeLabel: UILabel!

    var labels = [NSLocalizedString("id_support", comment: ""),
                  NSLocalizedString("id_view_my_recovery_phrase", comment: ""),
                  NSLocalizedString("id_device_authorization", comment: "")]

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.removeWallet))
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
            configureTableView()
            hideCreateWalletView()
            self.tableView.isHidden = false
            self.removeLabel.isHidden = false
            navigationItem.title = NSLocalizedString("id_settings", comment: "")
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

    @objc func removeWallet(_ sender: Any?) {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: NSLocalizedString("id_doublecheck_that_you_have_a", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .default) { _ in
            try? Mnemonic.delete()
            exit(0)
        })
        self.present(alert, animated: true, completion: nil)
    }

    func enableSafeMnemonic() {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: NSLocalizedString("id_do_you_want_to_enable_s", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .default) { _ in
            guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
                return self.showError(NSLocalizedString("id_invalid_mnemonic", comment: ""))
            }
            try? Mnemonic.delete()
            try? Mnemonic.write(mnemonic, safe: true)
        })
        self.present(alert, animated: true, completion: nil)
    }

    func disableSafeMnemonic() {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: NSLocalizedString("id_do_you_want_to_disable_s", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .default) { _ in
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
            // open email to support
            let email = "support@greenaddress.it"
            if let url = URL(string: "mailto:\(email)") {
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
        let storyboard = UIStoryboard(name: "Restore", bundle: .main)
        let restoreVC = storyboard.instantiateViewController(withIdentifier: "RestoreNavigationController")
        restoreVC.modalPresentationStyle = .fullScreen
        restoreVC.presentationController?.delegate = self
        present(restoreVC, animated: true, completion: nil)
    }

}

extension SettingsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        configure()
    }
}
