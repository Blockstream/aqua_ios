import UIKit
import PromiseKit

class NoteViewController: BaseViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!

    var transaction: Transaction!
    var updateTransaction: (_ transaction: Transaction) -> Void = { _ in }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCloseButton(on: .left)
        navigationController?.setNavigationBarHidden(false, animated: false)
        saveButton.isHidden = true
        memoTextView.round(radius: 17.5)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if !transaction.memo.isEmpty {
            memoTextView.text = transaction.memo
        }
        memoTextView.delegate = self
        saveButton.setTitle(NSLocalizedString("id_save", comment: ""), for: .normal)
        titleLabel.text = NSLocalizedString("id_add_a_note_to_yourself", comment: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        memoTextView.becomeFirstResponder()
    }

    @IBAction func saveClick(_ sender: Any) {
        guard let memo = memoTextView.text else { return }
        saveButton.isEnabled = false
        let bgq = DispatchQueue.global(qos: .background)
        let session = transaction.networkName == Liquid.networkName ? Liquid.shared.session : Bitcoin.shared.session
        Guarantee().map(on: bgq) { _ in
            try session?.setTransactionMemo(txhash_hex: self.transaction.hash, memo: memo, memo_type: 0)
            self.transaction.memo = memo
        }.ensure {
            self.saveButton.isEnabled = true
        }.done {
            self.saveButton.isHidden = true
            self.view.endEditing(true)
            self.dismiss(animated: true) {
                self.updateTransaction(self.transaction)
            }
        }.catch { err in
            self.showError(err.localizedDescription)
        }
    }
}

extension NoteViewController: UITextViewDelegate {

    func textViewDidChangeSelection(_ textView: UITextView) {
        saveButton.isHidden = !(textView.text?.count ?? 0 > 0)
    }
}
