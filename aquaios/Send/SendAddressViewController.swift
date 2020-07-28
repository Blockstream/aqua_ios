import UIKit
import PromiseKit

class SendAddressViewController: BaseViewController {

    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var pasteFromClipboardView: UIView!
    @IBOutlet weak var pasteViewTitleLabel: UILabel!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!

    var asset: Asset?

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("id_send_to", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.largeTitleDisplayMode = .never
        configureView()
        pasteFromClipboardView.isHidden = true
        pasteButton.isHidden = true
        showCloseButton(on: .left)
    }

    override func viewDidAppear(_ animated: Bool) {
        addressTextField.text = NSLocalizedString("id_input_address_or_scan_qr_code", comment: "")
        addressTextField.textColor = .teal
        addressTextField.clearsOnBeginEditing = true
        if let address = UIPasteboard.general.string {
            addressLabel.text = address
            pasteFromClipboardView.isHidden = true
            pasteButton.isHidden = true
            let bgq = DispatchQueue.global(qos: .background)
            let sharedNetwork = asset?.isBTC ?? false ? Bitcoin.shared : Liquid.shared
            Guarantee().compactMap(on: bgq) {_ -> RawTransaction in
                let tx = try sharedNetwork.createTransaction(address)
                if let error = tx.error, !error.isEmpty && error != NSLocalizedString("id_invalid_amount", comment: "") {
                    throw TransactionError.generic(error)
                }
                return tx
            }.done { _ in
                self.pasteFromClipboardView.isHidden = false
                self.pasteButton.isHidden = false
            }.catch { err in
                if let error = err as? TransactionError {
                    if case .generic(let desc) = error {
                        self.addressLabel.text = desc == "id_invalid_address" ? NSLocalizedString("id_clipboard_content_is_not_a", comment: "") : desc
                    }
                    self.pasteFromClipboardView.isHidden = false
                    self.pasteButton.isHidden = false
                    self.pasteButton.isEnabled = false
                }
            }
        }
    }

    func configureView() {
        textFieldBackgroundView.round(radius: 12)
        pasteFromClipboardView.round(radius: 18)
        pasteViewTitleLabel.text = NSLocalizedString("id_paste_from_clipboard", comment: "")
        addressTextField.tintColor = .topaz
    }

    @IBAction func qrButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "qr_code", sender: nil)
    }

    @IBAction func pasteButtonTapped(_ sender: Any) {
        if let address = addressLabel.text {
            addressTextField.text = address
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            performSendSegue(with: address)
        }
    }

    func createTransactionPromise(_ networkSession: NetworkSession, address: String) -> Promise<RawTransaction> {
        return Promise<RawTransaction> { seal in
            let tx = try networkSession.createTransaction(address)
            if let error = tx.error, error == NSLocalizedString("id_invalid_address", comment: "") {
                seal.reject(TransactionError.generic(error))
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
            if let error = tx.error, !error.isEmpty && error != NSLocalizedString("id_invalid_amount", comment: "") {
                throw TransactionError.generic(error)
            }
            var addressee = tx.addressees.first
            let txTag = addressee?.assetTag
            let inputTag = self.asset?.tag ?? (network == Bitcoin.networkName ? "btc" : Liquid.shared.policyAsset)
            if network == Bitcoin.networkName {
                if inputTag == "btc" && (txTag == nil || txTag == "btc") {
                    addressee?.assetTag = inputTag
                    self.performSegue(withIdentifier: "send_details", sender: addressee)
                } else {
                    self.showError(NSLocalizedString("id_liquid_addresses_are_invalid", comment: ""))
                }
            } else if network == Liquid.networkName {
                if inputTag != "btc" && (txTag != nil && txTag != "btc") {
                    if inputTag == txTag {
                        self.performSegue(withIdentifier: "send_details", sender: addressee)
                    } else {
                        self.showError(NSLocalizedString("id_assets_dont_match", comment: ""))
                    }
                } else if inputTag != "btc" && txTag == nil {
                    addressee?.assetTag = inputTag
                    self.performSegue(withIdentifier: "send_details", sender: addressee)
                } else {
                    self.showError(NSLocalizedString("id_bitcoin_addresses_are_invalid", comment: ""))
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
        if let dest = segue.destination as? QRCodeViewController {
            dest.hideActionButton = true
            dest.asset = asset
        } else if let dest = segue.destination as? SelectAssetViewController {
            dest.flow = .send
            dest.addressee = sender as? Addressee
        } else if let dest = segue.destination as? SendDetailsViewController {
            dest.addressee = sender as? Addressee
        }
    }
}

extension SendAddressViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == UIPasteboard.general.string {
            performSendSegue(with: string)
        }
        return true
    }
}
