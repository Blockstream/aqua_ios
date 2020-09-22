import UIKit

class AssetCell: UITableViewCell {

    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var fiatValueLabel: UILabel!
    @IBOutlet weak var assetBackgroundView: UIView!
    @IBOutlet weak var assetIconImageView: UIImageView!

    func configure(with asset: Asset) {
        backgroundColor = .aquaBackgroundBlue
        assetBackgroundView.round(radius: 18)
        assetNameLabel.text = asset.name ?? NSLocalizedString("id_unregistered_asset", comment: "")
        balanceLabel.text = asset.string()
        tickerLabel.text = asset.ticker ?? ""
        fiatValueLabel.text = ""
        assetIconImageView.image = asset.icon ?? UIImage(named: "asset_unknown")
        if asset.hasFiatRate {
            let fiat = Fiat.from(asset.sats ?? 0)
            fiatValueLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }
    }

    func hideAmounts() {
        balanceLabel.isHidden = true
        fiatValueLabel.isHidden = true
    }
}
