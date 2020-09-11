import Foundation
import UIKit

class SupportFooterCell: UITableViewCell {

    @IBOutlet weak var iosLabel: UILabel!
    @IBOutlet weak var appLabel: UILabel!

    func configure() {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        iosLabel.text = String(format: NSLocalizedString("id_ios_version", comment: "")) + " " + systemVersion
        appLabel.text = String(format: NSLocalizedString("id_app_version", comment: "")) + " " + appVersion!
    }
}
