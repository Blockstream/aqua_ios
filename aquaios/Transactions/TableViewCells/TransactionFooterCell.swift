import Foundation
import UIKit

class TransactionFooterCell: UITableViewCell {
    @IBOutlet weak var ExplorerButton: UIButton!

    private var url: String?

    func configure(with tx: Transaction) {
        ExplorerButton.setTitle(NSLocalizedString("id_view_in_blockstream_explorer", comment: ""), for: .normal)
        let subpath = tx.networkName == Liquid.networkName ? "liquid/" : ""
        url = "https://blockstream.info/\(subpath)\(tx.hash)"
    }

    @IBAction func tap(_ sender: Any) {
        if let path = url, let url = URL(string: path) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
