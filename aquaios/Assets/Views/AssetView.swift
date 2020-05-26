import UIKit

@IBDesignable
class AssetView: UIView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetTickerLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func configure(with asset: Asset, bgColor: UIColor, radius: CGFloat, hiddenBalance: Bool = false) {
        round(radius: radius)
        backgroundColor = bgColor
        iconImageView.image = asset.icon
        assetNameLabel.text = asset.name
        assetTickerLabel.text = asset.ticker
        balanceLabel.text = asset.string() ?? ""
        if asset.isBTC || asset.isLBTC {
            let fiat = Fiat.from(asset.sats ?? 0)
            fiatLabel.text = "\(Fiat.currency() ?? "") \( fiat ?? "")"
        }
        balanceLabel.isHidden = hiddenBalance
        fiatLabel.isHidden = hiddenBalance
    }
}
