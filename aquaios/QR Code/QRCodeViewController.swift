import UIKit
import AVFoundation
import PromiseKit

enum TxFlow {
    case send
    case receive
}

class QRCodeViewController: BaseViewController {

    @IBOutlet weak var scannerPreviewView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var scanQrLabel: UILabel!
    @IBOutlet weak var actionButtonBackgroundView: UIView!

    var asset: Asset?
    var hideActionButton: Bool = false
    weak var scannerDelegate: QRScannerDelegate?
    private var qrScanner: QRScanner?
    private var qrScreenshotReader: QRCodeScreenshotReader?
    private let picker = UIImagePickerController()
    private var network = Bitcoin.networkName
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override func viewDidLoad() {
        super.viewDidLoad()
        scannerPreviewView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        qrScanner = QRScanner(with: scannerPreviewView, delegate: self)
        qrScreenshotReader = QRCodeScreenshotReader(delegate: self)
        setupBlurEffect()
        startScanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanner()
        scanQrLabel.text = NSLocalizedString("id_scan_qr_code", comment: "")
        actionButton.titleLabel?.text = NSLocalizedString("id_my_qr", comment: "")
        actionButton.isHidden = hideActionButton
        actionButtonBackgroundView.isHidden = hideActionButton
        actionButtonBackgroundView.round(radius: 12)
    }

    func setupBlurEffect() {
        actionButtonBackgroundView.backgroundColor = .clear
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.round(radius: 16)
        actionButtonBackgroundView.insertSubview(blurView, at: 0)

        NSLayoutConstraint.activate([
        blurView.heightAnchor.constraint(equalTo: actionButtonBackgroundView.heightAnchor),
        blurView.widthAnchor.constraint(equalTo: actionButtonBackgroundView.widthAnchor)
        ])
    }

    func startScanner() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            qrScanner?.requestCaptureSessionStart()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted: Bool) in
                guard let strongSelf = self else { return }
                if granted {
                    DispatchQueue.main.async {
                        strongSelf.qrScanner?.requestCaptureSessionStart()
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("id_please_enable_camera", comment: ""),
                                                      message: NSLocalizedString("id_we_use_the_camera_to_scan_qr", comment: ""),
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("id_cancel", comment: ""), style: .cancel) { _ in })
                        alert.addAction(UIAlertAction(title: NSLocalizedString("id_next", comment: ""), style: .default) { _ in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        })
                        DispatchQueue.main.async {
                            strongSelf.presentingViewController?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    @IBAction func myQrButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "select_asset_receive", sender: nil)
    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismissModal(animated: true)
    }

    func createTransactionPromise(_ networkSession: NetworkSession, address: String) -> Promise<RawTransaction> {
        return Promise<RawTransaction> { seal in
            let tx = try networkSession.createTransaction(address)
            if let error = tx.error, !error.isEmpty {
                if error == "id_invalid_address" {
                    seal.reject(TransactionError.invalidAddress(error))
                }
            }
            seal.fulfill(tx)
        }
    }

    func performSendSegue(with address: String) {
        let bgq = DispatchQueue.global(qos: .background)
        var network = Bitcoin.networkName
        Guarantee().then(on: bgq) {_ in
            return self.createTransactionPromise(Bitcoin.shared, address: address)
        }.recover(on: bgq) {_ in
            return Promise<String> { seal in
                network = Liquid.networkName
                seal.fulfill(network)
            }.then {_ in
                return self.createTransactionPromise(Liquid.shared, address: address)
            }
        }.done { tx in
            if let error = tx.error, !error.isEmpty && error != "id_invalid_amount" {
                throw TransactionError.generic(error)
            }
            var addressee = tx.addressees.first
            let txTag = addressee?.assetId
            let inputTag = self.asset?.tag
            if network == Bitcoin.networkName {
                if (inputTag == nil || inputTag == "btc") &&
                    (txTag == nil || txTag == "btc") {
                    addressee?.assetId = inputTag ?? "btc"
                    self.performSegue(withIdentifier: "send_details", sender: addressee)
                } else {
                    self.showError(NSLocalizedString("id_bitcoin_addresses_are_invalid", comment: ""))
                }
            } else if network == Liquid.networkName {
                if (inputTag != nil && inputTag != "btc") &&
                    (txTag != nil && txTag != "btc") {
                    if inputTag == txTag {
                        self.performSegue(withIdentifier: "send_details", sender: addressee)
                    } else {
                        self.showError(NSLocalizedString("id_assets_dont_match", comment: ""))
                    }
                } else if (inputTag != nil && inputTag != "btc") && txTag == nil {
                    addressee?.assetId = inputTag ?? "btc"
                    self.performSegue(withIdentifier: "send_details", sender: addressee)
                } else if (txTag != nil && txTag != "btc") && inputTag == nil {
                    self.performSegue(withIdentifier: "send_details", sender: addressee)
                } else if txTag == nil && inputTag == nil {
                    self.performSegue(withIdentifier: "select_asset_send", sender: addressee)
                } else {
                    self.showError(NSLocalizedString("id_liquid_addresses_are_invalid", comment: ""))
                }
            }
        }.catch { err in
            if let error = err as? TransactionError {
                self.showError(error)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let id = segue.identifier
        if let dest = segue.destination as? SelectAssetViewController, id == "select_asset_receive" {
                dest.flow = TxFlow.receive
        } else if let dest = segue.destination as? SelectAssetViewController, id == "select_asset_send" {
                dest.flow = TxFlow.send
                dest.addressee = sender as? Addressee
        } else if let dest = segue.destination as? SendDetailsViewController, id == "send_details" {
                dest.addressee = sender as? Addressee
        }
    }
}

// MARK: - Image Selection

extension QRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            qrScreenshotReader?.qrCode(from: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - QR Scanning

extension QRCodeViewController: QRScannerDelegate {
    func didScanQRCode(with address: String) {
        scannerDelegate?.didScanQRCode(with: address)
        performSendSegue(with: address)
    }

    func scanningFailed(with error: Error) {
        scannerDelegate?.scanningFailed(with: error)
        dismissModal(animated: true)
    }
}
