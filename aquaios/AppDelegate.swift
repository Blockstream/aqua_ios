import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(false, forKey: Constants.Keys.hasShownBackup)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? Bitcoin.shared.disconnect()
        try? Liquid.shared.disconnect()
    }
}
