import UIKit

extension UIView {
    func round(radius: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }

    func round(radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        round(radius: radius)
        border(width: borderWidth, color: borderColor)
    }

    func shadow(radius: CGFloat, color: UIColor, offset: CGSize, opacity: Float) {
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }

    func border(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }

    @objc func setup() {
        let nibName = String(describing: type(of: self))
        guard let view = loadViewFromNib(nibName) else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["v": view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["v": view]))
    }

    func loadViewFromNib(_ nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func fadeInOut(duration: TimeInterval = 0.2, delay: TimeInterval = 0.0, hideAfter: TimeInterval = 2.0) {
        UIView.animate(withDuration: duration, delay: delay,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
            self.alpha = 1.0
        }, completion: { _ in
            self.fadeOut(duration: duration, delay: hideAfter)
        })
    }

    private func fadeOut(duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(withDuration: 0.5,
                       delay: delay,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        self.alpha = 0.0
        }, completion: nil)
    }
}
