import UIKit
import PromiseKit

class BuyContainerViewController: UIViewController {

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

    @IBOutlet weak var buyBtcView: UIView!
    @IBOutlet weak var buyLbtcView: UIView!
    @IBOutlet weak var buyBtcButton: UIButton!
    @IBOutlet weak var buyLbtcButton: UIButton!
    @IBOutlet weak var comingSoonLabel: UILabel!
    @IBOutlet weak var buyBtcLabel: UILabel!
    @IBOutlet weak var buyLbtcLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buyBtcButton.round(radius: 16)
        buyLbtcButton.round(radius: 16)
        comingSoonLabel.text = NSLocalizedString("id_more_options_coming_soon", comment: "")
        buyBtcButton.setTitle(NSLocalizedString("id_buy_btc", comment: ""), for: .normal)
        buyLbtcButton.setTitle(NSLocalizedString("id_buy_lbtc", comment: ""), for: .normal)
        buyBtcLabel.text = NSLocalizedString("id_buy_bitcoin_with_card_or_apple", comment: "")
        buyLbtcLabel.text = NSLocalizedString("id_buy_liquid_bitcoin_with_card_or", comment: "")
    }

    @IBAction func buyBtcTapped(_ sender: Any) {
        prepareBuy(isBtc: true)
    }
    @IBAction func buyLbtcTapped(_ sender: Any) {
        prepareBuy(isBtc: false)
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
            if !countries.contains(countryCode ?? "us") {
                throw WyreError.unsupportedCountry
            }
        }.then(on: bgq) {
            self.reserve(isBtc: isBtc)
        }.ensure {
            self.stopAnimating()
        }.done { res in
            if let path = res["url"] {
                let url = URL(string: path)
                UIApplication.shared.open(url!, options: [:])
                return
            } else {
                self.showError(NSLocalizedString("id_operation_failure", comment: ""))
            }
        }.catch { err in
            if let error = err as? WyreError {
                switch error {
                case .offline:
                    self.showError(NSLocalizedString("id_network_error", comment: ""))
                case .unsupportedCountry:
                    self.showError(NSLocalizedString("id_the_service_is_not_available_in", comment: ""))
                case .abort:
                    self.showError(NSLocalizedString("id_operation_failure", comment: ""))
                }
            }
        }
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
