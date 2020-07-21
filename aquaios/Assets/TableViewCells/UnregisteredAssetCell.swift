import Foundation
import UIKit

class UnregisteredAssetCell: UITableViewCell {

    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoText: UILabel!

    func setup(title: String, text: String) {
        backgroundColor = .aquaBackgroundBlue
        infoTitle.text = title
        infoText.text = text
    }

    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = infoText.text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
