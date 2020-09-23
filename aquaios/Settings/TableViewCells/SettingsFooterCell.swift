import Foundation
import UIKit

protocol SettingsFooterActions: class {
    func remove()
}

class SettingsFooterCell: UITableViewCell {

    @IBOutlet weak var removeButton: UIButton!
    weak var delegate: SettingsFooterActions?

    func configure() {
        removeButton.setTitle(NSLocalizedString("id_remove_wallet", comment: ""), for: .normal)
    }

    @IBAction func removeClick(_ sender: Any) {
        delegate?.remove()
    }
}
