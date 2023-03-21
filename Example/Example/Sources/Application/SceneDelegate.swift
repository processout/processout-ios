//
//  SceneDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

import UIKit
import ProcessOut

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = FeaturesBuilder().build()
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let url = userActivity.webpageURL {
            _ = ProcessOutApi.shared.processDeepLink(url: url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        if let url = urlContexts.first?.url {
            _ = ProcessOutApi.shared.processDeepLink(url: url)
        }
    }
}
