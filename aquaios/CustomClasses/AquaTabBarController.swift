import UIKit

class AquaTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .topaz
        UITabBar.appearance().barTintColor = .aquaBackgroundBlue
        UITabBar.appearance().unselectedItemTintColor = .auroMetalSaurus
        UITabBar.appearance().backgroundColor = .aquaBackgroundBlue
        UITabBar.appearance().isOpaque = false
    }
}
