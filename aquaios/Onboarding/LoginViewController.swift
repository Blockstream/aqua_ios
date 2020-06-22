import Foundation
import UIKit
import PromiseKit

class LoginViewController: UIViewController {
    @IBOutlet weak var wallpaper: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !Mnemonic.supportsPasscodeAuthentication() {
            showError("Enable passcode in iPhone settings to continue")
            return
        }
        if hasWallet {
            load()
        } else {
            wait()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }

    func configure() {
        let gl = CAGradientLayer()
        gl.colors = [UIColor.topaz.cgColor, UIColor.deepTeal.cgColor]
        gl.locations = [0.0, 1.0]
        gl.frame = wallpaper.frame
        wallpaper.layer.insertSublayer(gl, at: 0)
    }

    func load() {
        guard let mnemonic = try? Mnemonic.read() else {
            let alert = UIAlertController(title: "Error", message: "Access failure", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.load() }))
            self.present(alert, animated: true)
            return
        }
        login(mnemonic)
    }

    func wait() {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            return Guarantee()
        }.map(on: bgq) {
            sleep(2)
        }.done { _ in
            self.performSegue(withIdentifier: "next", sender: nil)
        }
    }

    func login(_ mnemonic: String) {
        let bgq = DispatchQueue.global(qos: .background)
        firstly {
            return Guarantee()
        }.map(on: bgq) {
            try Liquid.shared.disconnect()
            try Bitcoin.shared.disconnect()
        }.map(on: bgq) {
            try Liquid.shared.connect()
            try Bitcoin.shared.connect()
        }.map(on: bgq) {
            try Liquid.shared.login(mnemonic)
            try Bitcoin.shared.login(mnemonic)
        }.compactMap(on: bgq) {
            try? Registry.shared.refresh(Liquid.shared.session!)
        }.ensure {
        }.done { _ in
            self.performSegue(withIdentifier: "next", sender: nil)
        }.catch { _ in
            let alert = UIAlertController(title: "Error", message: "Login failure.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.login(mnemonic) }))
            self.present(alert, animated: true)
        }
    }

}
