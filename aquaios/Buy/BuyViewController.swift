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
    #if DEBUG
    private let baseUrl = "https://staging-wyre.blockstream.com"
    private let wyreUrl = "https://api.testwyre.com"
    #else
    private let baseUrl = "https://wyre.blockstream.com"
    private let wyreUrl = "https://api.sendwyre.com"
    #endif

    public enum WyreError: Error {
        case offline
        case unsupportedCountry
        case abort
    }

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
        let countryCode = (NSLocale.current as NSLocale).object(forKey: .countryCode) as? String

        firstly {
            self.startAnimating()
            return Guarantee()
        }.then(on: bgq) {
            self.supportedCountries()
        }.map(on: bgq) { countries in
            if !countries.contains(countryCode!) {
                throw WyreError.unsupportedCountry
            }
        }.then(on: bgq) {
            self.reserve(isBtc: true)
        }.ensure {
            self.stopAnimating()
        }.done { res in
            if let path = res["url"] {
                let url = URL(string: path)
                UIApplication.shared.open(url!, options: [:])
                return
            } else {
                self.showError(NSLocalizedString("Error opening Wyre widget", comment: ""))
            }
        }.catch { err in
            if let error = err as? WyreError {
                switch error {
                case .offline:
                    self.showError(NSLocalizedString("Offline", comment: ""))
                case .unsupportedCountry:
                    self.showError(NSLocalizedString("Unsupported country", comment: ""))
                case .abort:
                    self.showError(NSLocalizedString("Operation Failure", comment: ""))
                }
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
    }

    @objc func createOrRestore(_ sender: Any?) {
        performSegue(withIdentifier: "create_wallet_alert", sender: nil)
    }

    func supportedCountries() -> Promise<[String]> {
        var request = URLRequest(url: URL(string: wyreUrl + "/v3/widget/supportedCountries")!)
        request.allHTTPHeaderFields = [ "Content-Type": "application/json" ]
        return Promise { seal in
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
                if error != nil {
                    return seal.reject(WyreError.offline)
                }
                if let list = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String] {
                    print(list)
                    return seal.fulfill(list)
                }
                return seal.reject(WyreError.abort)
            })
            task.resume()
        }
    }

    func reserve(isBtc: Bool) -> Promise<[String: String]> {
        var request = URLRequest(url: URL(string: baseUrl + "/order-reservation")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [ "Content-Type": "application/json",
                                        "Accept": "application/json" ]
        let address = isBtc ? Bitcoin.shared.address : Liquid.shared.address
        let destCurrency = isBtc ? "BTC" : "LBTC"
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [URLQueryItem(name: "paymentMethod", value: "apple-pay"),
                                     URLQueryItem(name: "destCurrency", value: destCurrency),
                                     URLQueryItem(name: "dest", value: address)]
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        return Promise { seal in
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
                if let error = error {
                    print(error)
                    return seal.reject(WyreError.offline)
                }
                if let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                    print(json)
                    return seal.fulfill(json)
                }
                return seal.reject(WyreError.abort)
            })
            task.resume()
        }
    }
}
