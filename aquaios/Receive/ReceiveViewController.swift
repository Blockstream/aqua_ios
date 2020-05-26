import UIKit
import PromiseKit

class ReceiveViewController: BaseViewController {

    @IBOutlet weak var assetView: AssetView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var specifyButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var setAmountButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var addressBackgroundView: UIView!
    @IBOutlet weak var qrImageBackgroundView: UIView!
    @IBOutlet weak var feedbackView: UIView!

    var asset: Asset?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        configure()
    }

    func configure() {
        assetView.configure(with: asset!, bgColor: .lighterBlueGray, radius: 18, hiddenBalance: true)
        navigationController?.setNavigationBarHidden(false, animated: false)

        title = String(format: "Receive")
        tabBarController?.tabBar.isHidden = !isModalPresenting
        feedbackView.alpha = 0.0
        feedbackView.round(radius: 17.5)
        qrImageBackgroundView.round(radius: 20)
        for button in [copyButton, setAmountButton, shareButton] {
            button?.round(radius: 0.5 * (button?.bounds.width)!)
            button?.setBackgroundColor(color: .teal, for: .highlighted)
        }
        addressBackgroundView.round(radius: 6)
        showCloseButton(on: .left)
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
            let alert = UIAlertController(title: "Error", message: "Address Generation Failure", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.reloadData() }))
            self.present(alert, animated: true)
        }
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let uri = addressLabel.text
        let avc = UIActivityViewController(activityItems: [uri ?? ""], applicationActivities: nil)
        avc.popoverPresentationController?.sourceView = self.view
        present(avc, animated: true, completion: nil)
    }

    @IBAction func specifyButtonTapped(_ sender: Any) {
    }

    @IBAction func copyButtonTapped(_ sender: Any) {
        feedbackView.fadeInOut()
        UIPasteboard.general.string = addressLabel.text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @IBAction func noteButtonTapped(_ sender: Any) {
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        presentingViewController?.dismissModal(animated: true)
    }
}
