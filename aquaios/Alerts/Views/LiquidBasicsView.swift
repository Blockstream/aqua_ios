import UIKit

@IBDesignable
class LiquidBasicsView: UIView {
    var contentView:UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }

    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
                    [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        configure()
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LiquidBasicsView", bundle: bundle)
        return nib.instantiate( withOwner: self, options: nil).first as? UIView
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }

    private func configure() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        contentView?.addGestureRecognizer(tapGestureRecognizer)
        contentView?.isUserInteractionEnabled = true
    }

    @objc func tap() {
        let path = "https://blockstream.zendesk.com/hc/en-us/sections/900000129806-Liquid-Explained"
        if let url = URL(string: path) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
