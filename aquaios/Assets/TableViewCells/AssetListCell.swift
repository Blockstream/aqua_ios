import UIKit

class AssetListCell: UITableViewCell {

    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var fiatValueLabel: UILabel!
    @IBOutlet weak var assetBackgroundView: UIView!
    @IBOutlet weak var assetIconImageView: UIImageView!

    func configure(with asset: Asset) {
        backgroundColor = .aquaBackgroundBlue
        assetBackgroundView.round(radius: 18)
        assetNameLabel.text = asset.name ?? "Unregistered asset"
        balanceLabel.text = asset.string()
        tickerLabel.text = asset.ticker ?? ""
        fiatValueLabel.text = ""
        assetIconImageView.image = asset.icon ?? UIImage(named: "asset_unknown")
        if !asset.selectable {
            let fiat = Fiat.from(asset.sats ?? 0)
            fiatValueLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }
        selectionStyle = .none
    }
}
