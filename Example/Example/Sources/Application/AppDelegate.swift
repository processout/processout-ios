//
//  AppDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

import UIKit
@_spi(PO) import ProcessOut
import ProcessOutUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureProcessOut()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Private Methods

    private func configureProcessOut() {
        // Please note that implementation is using factory method (part of private interface) that creates
        // configuration with private key. It is only done for demonstration/testing purposes to avoid setting
        // up test server and shouldn't be shipped with production code.
        let configuration = ProcessOutConfiguration.production(
            projectId: Constants.projectId, privateKey: Constants.projectPrivateKey
        )
        ProcessOut.configure(configuration: configuration)
        ProcessOutUI.configure()
    }
}
