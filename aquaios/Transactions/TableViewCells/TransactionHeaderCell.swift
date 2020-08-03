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
        pendingLabel.isHidden = tx.blockHeight > 0
        dateLabel.text = AquaService.date(from: tx.createdAt, dateStyle: .medium, timeStyle: .medium)
    }
}
