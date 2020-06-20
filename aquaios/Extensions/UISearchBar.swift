import Foundation
import UIKit

extension UISearchBar {
    
    func appearance() {
        barStyle = .default
        isTranslucent = true
        showsCancelButton = false
        showsBookmarkButton = false
        backgroundColor = .aquaShadowBlue
        tintColor = .aquaBackgroundBlue
        barTintColor = .aquaBackgroundBlue

        if #available(iOS 13.0, *) {
            let textField = searchTextField
            textField.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            textField.textColor = .auroMetalSaurus
            textField.tintColor = .aquaBackgroundBlue
            textField.backgroundColor = .aquaShadowBlue
        }
    }
}
