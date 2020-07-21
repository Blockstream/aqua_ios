import Foundation
import UIKit

class TransactionHeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with tx: Transaction) {
        if tx.incoming {
            titleLabel.text = NSLocalizedString("id_received", comment: "")
        } else if tx.outgoing {
            titleLabel.text = NSLocalizedString("id_sent", comment: "")
        } else {
            titleLabel.text = NSLocalizedString("id_redeposit", comment: "")
        }
        if tx.networkName == Bitcoin.networkName {
            pendingLabel.isHidden = tx.blockHeight < Bitcoin.shared.blockHeight + 5
        } else {
            pendingLabel.isHidden = tx.blockHeight < Bitcoin.shared.blockHeight + 1
        }
        dateLabel.text = AquaService.date(from: tx.createdAt, dateStyle: .medium, timeStyle: .medium)
    }
}
