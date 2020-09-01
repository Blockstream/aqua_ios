import Foundation
import UIKit

protocol SettingsFooterActions: class {
    func remove()
}

class SettingsFooterCell: UITableViewCell {

    @IBOutlet weak var removeButton: UIButton!
    weak var delegate: SettingsFooterActions?

    @IBAction func removeClick(_ sender: Any) {
        delegate?.remove()
    }
}
