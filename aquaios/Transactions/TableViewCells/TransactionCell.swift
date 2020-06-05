import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denominationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func prepareForReuse() {
        amountLabel.text = ""
        denominationLabel.text = ""
        dateLabel.text = ""
        notesLabel.text = ""
    }

    func configure(with tx: Transaction) {
        backgroundColor = .aquaBackgroundBlue
        let tag = tx.defaultAsset
        let amount = tx.satoshi[tag]
        let asset = Asset(info: Registry.shared.info(for: tag), tag: tag)
        let prefix = tx.type == "outgoing" ? "-" : "+"
        amountLabel.text = "\(prefix)\(asset.string(amount ?? 0) ?? "")"
        denominationLabel.text = asset.ticker
        dateLabel.text = AquaService.date(from: tx.createdAt)
        notesLabel.text = tx.memo
        let fiat = Fiat.from(amount ?? 0)
        fiatLabel.text = asset.isBTC || asset.isLBTC ? "\(prefix)\(Fiat.currency() ?? "") \(fiat ?? "")" : ""
        iconImageView.image = UIImage(named: tx.type)
        selectionStyle = .none
    }
}
