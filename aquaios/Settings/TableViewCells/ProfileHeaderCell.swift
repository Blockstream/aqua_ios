import Foundation
import UIKit

class ProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var liquidBasicsView: LiquidBasicsView!

    func configure() {
        liquidBasicsView.round(radius: 24)
    }
}
