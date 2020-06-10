import UIKit

class AssetTitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func configure(with asset: Asset) {
        titleLabel.text = asset.name ?? "Unregistered Asset"
        iconImageView.image = asset.icon ?? UIImage(named: "asset_unknown")
    }
}
