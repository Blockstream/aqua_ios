import Foundation
import UIKit

class AvailableFooterCell: UITableViewCell {

    var click: () -> Void = {  }
    @IBOutlet weak var titleLabel: UILabel!

    func configure() {
        titleLabel.text = NSLocalizedString("id_which_platforms_supports", comment: "")
        let tapLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        titleLabel.addGestureRecognizer(tapLabel)
        titleLabel.isUserInteractionEnabled = true
    }

    @objc func tap() {
        click()
    }
}
