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
        guard let mnemonic = try? Mnemonic.generate() else {
            return showError("No mnemonic generated")
        }
        register(mnemonic: mnemonic)
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
            try Liquid.shared.login(mnemonic)
            try Bitcoin.shared.login(mnemonic)
        }.compactMap(on: bgq) {
            try? Registry.shared.refresh(Liquid.shared.session!)
        }.ensure {
            self.stopAnimating()
        }.done { _ in
            self.performSegue(withIdentifier: "next", sender: nil)
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
