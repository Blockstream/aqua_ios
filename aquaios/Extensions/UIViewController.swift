import UIKit
import PromiseKit

extension UIViewController {

    var hasWallet: Bool {
        get {
            return Mnemonic.exist()
        }
    }

    private var hasBackedUp: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.Keys.hasBackedUp) == true
        }
    }

    private var hasShownBackup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.Keys.hasShownBackup) == true
        }
    }

    var isModalPresenting: Bool {
        let modalPresenting = presentingViewController != nil
        let navigationPresenting = navigationController?.presentingViewController?.presentedViewController == navigationController
        let tabBarPresenting = tabBarController?.presentingViewController is UITabBarController
        return modalPresenting || navigationPresenting || tabBarPresenting
    }

    func dismissModal(animated: Bool, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            if let presentationController = presentationController {
                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
            }
        }
        dismiss(animated: animated, completion: completion)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .cancel) { _ in })
        self.present(alert, animated: true, completion: nil)
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("id_continue", comment: ""), style: .cancel) { _ in })
        self.present(alert, animated: true, completion: nil)
    }

    func showBackupIfNeeded() {
        if !hasBackedUp && !hasShownBackup {
            UserDefaults.standard.set(true, forKey: Constants.Keys.hasShownBackup)
            showBackupAlert()
        }
    }

    func showBackupIfNotified() {
        if !hasBackedUp {
                showBackupAlert()
            }
        }

    func showBackupNag() {
        let storyboard = UIStoryboard(name: "Alerts", bundle: .main)
        let nagAlert = storyboard.instantiateViewController(withIdentifier: "BackupNagViewController")
        nagAlert.modalPresentationStyle = .overFullScreen
        nagAlert.modalTransitionStyle = .crossDissolve
        present(nagAlert, animated: true, completion: nil)
    }

    func showBackupAlert() {
        let storyboard = UIStoryboard(name: "Alerts", bundle: .main)
        let backupAlert = storyboard.instantiateViewController(withIdentifier: "BackupAlertViewController")
        backupAlert.modalPresentationStyle = .overFullScreen
        backupAlert.modalTransitionStyle = .crossDissolve
        present(backupAlert, animated: true, completion: nil)
    }

    func showOnboarding(with presentationDelegate: UIAdaptivePresentationControllerDelegate) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: .main)
        let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingNavigationController")
        onboardingVC.modalPresentationStyle = .fullScreen
        onboardingVC.presentationController?.delegate = presentationDelegate
        present(onboardingVC, animated: true, completion: nil)
    }

    func showError(_ error: TransactionError) {
        let alert = UIAlertController(title: NSLocalizedString("id_warning", comment: ""), message: "", preferredStyle: .alert)
        switch error {
        case .generic(let desc), .invalidAmount(let desc), .invalidAddress(let desc):
            alert.message = NSLocalizedString(desc, comment: "")
        }
        alert.addAction(UIAlertAction(title: "id_continue", style: .default, handler: { _ in }))
        self.present(alert, animated: true)
    }
}
