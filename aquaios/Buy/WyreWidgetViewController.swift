import UIKit
import WebKit

class WyreWidgetViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!

    var buyBtc: Bool?
    private var btcAddress = Bitcoin.shared.address ?? ""
    private var lbtcAddress = Liquid.shared.address ?? ""
    private var successURLString = "aquaios:wyresuccess"
    private var failureURLString = "aquaios:wyrefailure"

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let address = buyBtc ?? true ? btcAddress : lbtcAddress
        let destCurrency = buyBtc ?? true ? "BTC" : "LBTC"
        if let url = URL(string: "https://pay.sendwyre.com/purchase?destCurrency=\(destCurrency )&dest=\(address)&redirectUrl=\(successURLString)&failureRedirectUrl=\(failureURLString)") {
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
