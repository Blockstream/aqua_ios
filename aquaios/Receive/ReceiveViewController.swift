import UIKit
import PromiseKit

class ReceiveViewController: BaseViewController {

    @IBOutlet weak var assetView: AssetView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var specifyButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!

    @IBOutlet weak var addressBackgroundView: UIView!
    @IBOutlet weak var qrImageBackgroundView: UIView!
    @IBOutlet weak var feedbackView: UIView!

    var asset: Asset?
    var showCloseButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        configure()
    }

    func configure() {
        assetView.configure(with: asset, bgColor: .lighterBlueGray, radius: 18, hiddenBalance: true)
        navigationController?.setNavigationBarHidden(false, animated: false)
        if showCloseButton {
            showCloseButton(on: .left)
        }
        title = NSLocalizedString("id_receive", comment: "")
        tabBarController?.tabBar.isHidden = !isModalPresenting
        feedbackView.alpha = 0.0
        feedbackView.round(radius: 17.5)
        qrImageBackgroundView.round(radius: 20)
        for button in [copyButton, shareButton] {
            button?.round(radius: 0.5 * (button?.bounds.width)!)
            button?.setBackgroundColor(color: .teal, for: .highlighted)
        }
        addressBackgroundView.round(radius: 6)
        copyLabel.text = NSLocalizedString("id_copy", comment: "")
        shareLabel.text = NSLocalizedString("id_share", comment: "")
    }

    func reloadData() {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            return Guarantee()
        }.compactMap(on: bgq) {
            return self.asset?.tag == "btc" ? Bitcoin.shared.address : Liquid.shared.address
        }.done { address in
            self.addressLabel.text = address
            self.qrImageView.image = QRImageGenerator.imageForTextWhite(text: address, frame: self.qrImageView.frame)
        }.catch { _ in
            let alert = UIAlertController(title: NSLocalizedString("id_error", comment: ""), message: NSLocalizedString("id_address_generation_failed", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("id_retry", comment: ""), style: .default, handler: { _ in self.reloadData() }))
            self.present(alert, animated: true)
        }
    }

    func handleCopyEvent() {
        feedbackView.fadeInOut()
        UIPasteboard.general.string = addressLabel.text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @IBAction func onQrCodeImageTap(_ sender: Any) {
        handleCopyEvent()
    }

    @IBAction func onAddressLabelTap(_ sender: Any) {
        handleCopyEvent()
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let uri = addressLabel.text
        let avc = UIActivityViewController(activityItems: [uri ?? ""], applicationActivities: nil)
        avc.popoverPresentationController?.sourceView = self.view
        present(avc, animated: true, completion: nil)
    }

    @IBAction func copyButtonTapped(_ sender: Any) {
        handleCopyEvent()
    }
}
