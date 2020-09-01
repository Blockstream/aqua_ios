import Foundation
import UIKit

protocol SettingsFooterActions {
    func remove()
}

class SettingsFooterCell: UITableViewCell {

    @IBOutlet weak var removeButton: UIButton!
    var delegate: SettingsFooterActions?

    @IBAction func removeClick(_ sender: Any) {
        delegate?.remove()
    }
}
