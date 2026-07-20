import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: winScene)
        w.rootViewController = UIHostingController(rootView: ContentView())
        window = w
        w.makeKeyAndVisible()
    }
}
