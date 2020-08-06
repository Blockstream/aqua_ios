import UIKit

enum CloseButtonSide {
    case left
    case right
}

class BaseViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setNavigationBarBackgroundColor(.aquaBackgroundBlue)
    }

    func setNavigationBarBackgroundColor(_ color: UIColor) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = color
            barAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            barAppearance.shadowColor = .clear
            barAppearance.shadowImage = UIImage()
            barAppearance.titleTextAttributes = titleAttributes
            navigationController?.navigationBar.standardAppearance = barAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        }
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.backgroundColor = color
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layoutIfNeeded()
    }

    func showCloseButton(on side: CloseButtonSide) {
        let dismissButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(dismissTapped))
        switch side {
        case .left:
            navigationItem.leftBarButtonItem = dismissButton
        case .right:
            navigationItem.rightBarButtonItem = dismissButton
        }
    }

    @objc func dismissTapped(_ sender: Any) {
        dismissModal(animated: true)
    }
}
