import UIKit
import PromiseKit

class BuyViewController: BaseViewController {

    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyIconView: UIView!
    @IBOutlet weak var buyBtcView: UIView! // !!!
    @IBOutlet weak var buyLbtcView: UIView! //
    @IBOutlet weak var buyBtcButton: UIButton!
    @IBOutlet weak var buyLbtcButton: UIButton!
    @IBOutlet weak var comingSoonLabel: UILabel!
    private var wyreAllowed: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("id_exchange", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        buyBtcButton.round(radius: 16)
        buyLbtcButton.round(radius: 16)
        configurePreLogin()
        if hasWallet {
            buyView.isHidden = true
            buyBtcView.isHidden = false
            buyLbtcView.isHidden = false
            comingSoonLabel.isHidden = false
        } else {
            buyBtcView.isHidden = true
            buyLbtcView.isHidden = true
            comingSoonLabel.isHidden = true
        }
    }

    func prepareBuy(isBtc: Bool) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            self.startAnimating()
            return Guarantee()
        }.then(on: bgq) {
            self.reserve()
        }.ensure {
            self.stopAnimating()
        }.done {  res in
            if let path = res["url"] {
                let address = isBtc ? Bitcoin.shared.address : Liquid.shared.address
                let destCurrency = isBtc ? "BTC" : "LBTC"
                let url = URL(string: "\(path)&destCurrency=\(destCurrency)&dest=\(address!)")
                UIApplication.shared.open(url!, options: [:])
                return
            } else {
                // GET /location/widget not available in v3
                self.showAlert(title: "Error", message: "Missing url")
            }
        }
    }

    @IBAction func buyBtcTapped(_ sender: Any) {
        prepareBuy(isBtc: true)
    }
    @IBAction func buyLbtcTapped(_ sender: Any) {
        prepareBuy(isBtc: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CreateWalletAlertController {
            dest.delegateVC = self
        }
    }

    func configurePreLogin() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createOrRestore))
        buyView.addGestureRecognizer(tapGestureRecognizer)
        buyView.isUserInteractionEnabled = true
        buyView.round(radius: 24)
        buyIconView.round(radius: 24)
    }

    @objc func createOrRestore(_ sender: Any?) {
        performSegue(withIdentifier: "create_wallet_alert", sender: nil)
    }

    func reserve() -> Promise<[String: String]> {
        let url = URL(string: "https://api.testwyre.com/v3/orders/reserve")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [ "Content-Type": "application/json",
                                        "Accept": "application/json",
                                        "Authorization": "Bearer SK-X4F6UAXL-LNCFNU63-2TC4NGRG-T3EPCUZD" ]
        let params = ["referrerAccountId": "AC_82VYBNNYG32"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        return Promise { seal in
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
                if let error = error {
                    print(error)
                    return seal.reject(GaError.GenericError)
                }
                if let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                    print(json)
                    return seal.fulfill(json)
                }
                return seal.reject(GaError.GenericError)
            })
            task.resume()
        }
    }
}
