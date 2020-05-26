import UIKit
import WebKit
import PromiseKit

class TermsOfServiceViewController: BaseViewController {

    @IBOutlet weak var tosWebView: WKWebView!
    @IBOutlet weak var agreementLabel: UIView!
    @IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tosURL = URL(string: "https://blockstream.com/green/terms/") {
            let request = URLRequest(url: tosURL)
            tosWebView.load(request)
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        register(mnemonic: try! generateMnemonic12())
    }

    func register(mnemonic: String) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating(message: NSLocalizedString("id_logging_in", comment: ""))
            return Guarantee()
        }.map(on: bgq) {
            try Liquid.shared.disconnect()
            try Bitcoin.shared.disconnect()
        }.map(on: bgq) {
            try Liquid.shared.connect()
            try Bitcoin.shared.connect()
        }.map(on: bgq) {
            try Liquid.shared.register(mnemonic)
            try Bitcoin.shared.register(mnemonic)
        }.ensure {
            self.stopAnimating()
        }.done { _ in
            UserDefaults.standard.set(mnemonic, forKey: Constants.Keys.mnemonic)
            self.login { (success) in
                guard success == true else { return }
                self.navigationController?.topViewController?.dismissModal(animated: true)
            }
        }.catch { error in
            let message: String
            if let err = error as? GaError, err != GaError.GenericError {
                message = NSLocalizedString("id_connection_failed", comment: "")
            } else {
                message = NSLocalizedString("id_login_failed", comment: "")
            }
            self.showError(message)
        }
    }
}
