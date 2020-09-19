import Foundation
import UIKit

class AvailableFooterCell: UITableViewCell {

    var click: () -> Void = {  }
    @IBOutlet weak var titleLabel: UILabel!

    func configure() {
        let tapLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        titleLabel.addGestureRecognizer(tapLabel)
        titleLabel.isUserInteractionEnabled = true
    }

    @objc func tap() {
        click()
    }
}
