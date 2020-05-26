import UIKit

class AquaSearchBar: UISearchBar {

    var font: UIFont!
    var textColor: UIColor!

    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        self.font = font
        self.textColor = textColor
        searchBarStyle = .default
        isTranslucent = true
        showsCancelButton = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        for view in subviews[0].subviews[1].subviews {
            if let textField = view as? UITextField {
                textField.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 48)
                textField.font = font
                textField.textColor = textColor
                textField.backgroundColor = .aquaShadowBlue
            }
        }
        super.draw(rect)
    }
}
