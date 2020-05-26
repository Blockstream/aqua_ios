import UIKit

class AddAssetCell: UITableViewCell {
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!

    func configure(with asset: Asset) {
        backgroundColor = .white
        assetNameLabel.text = asset.name ?? ""
        tickerLabel.text = asset.ticker ?? ""
    }
}
