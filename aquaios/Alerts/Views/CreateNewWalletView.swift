import Foundation
import UIKit

@IBDesignable
class CreateNewWalletView: UIView {

    var contentView: UIView?
    weak var delegate: CreateWalletDelegate?

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alreadyHaveAWalletLabel: UILabel!
    @IBOutlet weak var createNewWalletLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }

    private func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
                    [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        configure()
    }

    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CreateNewWalletView", bundle: bundle)
        return nib.instantiate( withOwner: self, options: nil).first as? UIView
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }

    private func configure() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createButtonTapped))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        backgroundView.isUserInteractionEnabled = true
        backgroundView.round(radius: 24)
    }

    @IBAction func restoreButtonTapped(_ sender: Any) {
        delegate?.didTapRestore()
    }

    @objc func createButtonTapped() {
        delegate?.didTapCreate()
    }
}
