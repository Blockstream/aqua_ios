import UIKit

protocol CreateWalletDelegate: class {
    func didTapCreate()
    func didTapRestore()
}

class CreateWalletView: UIView {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var existingWalletLabel: UILabel!

    weak var delegate: CreateWalletDelegate?
    static let tag = 0x70726F67726574C0

    init() {
        super.init(frame: .zero)
        tag = CreateWalletView.tag
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func activateConstraints(in parentView: UIView) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            self.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            self.heightAnchor.constraint(equalToConstant: 186),
            self.widthAnchor.constraint(equalTo: parentView.widthAnchor)
        ])
        createButton.round(radius: 24)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        createButton.setTitle(NSLocalizedString("id_create_a_new_wallet", comment: ""), for: .normal)
        restoreButton.setTitle(NSLocalizedString("id_restore_an_aqua_wallet", comment: ""), for: .normal)
        existingWalletLabel.text = NSLocalizedString("id_already_have_an_aqua_wallet", comment: "")
    }

    @objc func createButtonTapped() {
        delegate?.didTapCreate()
    }

    @objc func restoreButtonTapped() {
        delegate?.didTapRestore()
    }
}

extension UIViewController {

    private var createWalletView: CreateWalletView? {
        get {
            return UIApplication.shared.keyWindow?.viewWithTag(CreateWalletView.tag) as? CreateWalletView
        }
    }

    func showCreateWalletView(delegate: CreateWalletDelegate) {
        if createWalletView == nil {
            let createWalletView = CreateWalletView()
            view.addSubview(createWalletView)
            view.bringSubviewToFront(createWalletView)
        }
        createWalletView?.delegate = delegate
        createWalletView?.activateConstraints(in: view)
    }

    @objc func hideCreateWalletView() {
        view.subviews.forEach { view in
            if let cwn = view.viewWithTag(CreateWalletView.tag) as? CreateWalletView {
                cwn.delegate = nil
                cwn.removeFromSuperview()
            }
        }
    }
}
