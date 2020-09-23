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
    @IBOutlet weak var restoreButton: UIButton!

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

        createNewWalletLabel.text = NSLocalizedString("id_create_a_new_wallet", comment: "")
        descriptionLabel.text = NSLocalizedString("id_your_wallet_will_support", comment: "")
        alreadyHaveAWalletLabel.text = NSLocalizedString("id_already_have_an_aqua_wallet", comment: "")
        restoreButton.setTitle(NSLocalizedString("id_restore", comment: ""), for: .normal)
    }

    @IBAction func restoreButtonTapped(_ sender: Any) {
        delegate?.didTapRestore()
    }

    @objc func createButtonTapped() {
        delegate?.didTapCreate()
    }
}
