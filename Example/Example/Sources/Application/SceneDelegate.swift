//
//  SceneDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

import SwiftUI
import ProcessOut

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        if let url = urlContexts.first?.url {
            ProcessOut.shared.processDeepLink(url: url)
        }
    }
}
