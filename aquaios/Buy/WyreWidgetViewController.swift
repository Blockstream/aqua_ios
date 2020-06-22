import UIKit
import WebKit

class WyreWidgetViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!

    var buyBtc: Bool?
    private var btcAddress = Bitcoin.shared.address ?? ""
    private var lbtcAddress = Liquid.shared.address ?? ""
    private var success = "aquaios:wyresuccess"
    private var failure = "aquaios:wyrefailure"

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let address = buyBtc ?? true ? btcAddress : lbtcAddress
        let destCurrency = buyBtc ?? true ? "BTC" : "LBTC"
        if let url = URL(string: "https://pay.sendwyre.com/purchase?destCurrency=\(destCurrency )&dest=\(address)&redirectUrl=\(success)&failureRedirectUrl=\(failure)") {
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
        let urlString = navigationAction.request.url?.absoluteString
        if urlString?.starts(with: success) ?? false {
            // On a successful buy can intercept the orderId
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopAnimating()
    }
}
