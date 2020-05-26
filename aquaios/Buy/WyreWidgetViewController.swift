import UIKit
import WebKit

class WyreWidgetViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!

    var ticker: String?
    private var btcAddress = "3KL9B4232SW35SaRywrTTEbrWWbnpvfc1c"
    private var lbtcAddress = Liquid.shared.address ?? ""
    private var successURLString = "aquaios:wyresuccess"
    private var failureURLString = "aquaios:wyrefailure"

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let address = ticker == "BTC" ? btcAddress : lbtcAddress
        let destCurrency = ticker == "L-BTC" ? "LBTC" : ticker
        if let url = URL(string: "https://pay.sendwyre.com/purchase?destCurrency=\(destCurrency ?? "BTC")&dest=\(address)&redirectUrl=\(successURLString)&failureRedirectUrl=\(failureURLString)") {
            let request = URLRequest(url: url)
            webView.load(request)
            startAnimating()
        }
    }
}

extension WyreWidgetViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navType = navigationAction.navigationType
        switch  navType {
        case .other:
            let urlString = navigationAction.request.url?.absoluteString
            if urlString == successURLString {
                // On a successful buy can intercept the txid here
                dismissModal(animated: true)
            }
        default:
            dismissModal(animated: true)
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopAnimating()
    }
}
