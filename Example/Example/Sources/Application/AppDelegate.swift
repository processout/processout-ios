//
//  AppDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

import UIKit
@_spi(PO) import ProcessOut

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
        let configuration = ProcessOutApiConfiguration.staging(
            projectId: Constants.projectId,
            privateKey: Constants.projectPrivateKey,
            // swiftlint:disable force_unwrapping
            apiBaseUrl: URL(string: Constants.apiBaseUrl)!,
            checkoutBaseUrl: URL(string: Constants.checkoutBaseUrl)!
            // swiftlint:enable force_unwrapping
        )
        ProcessOutApi.configure(configuration: configuration)
    }
}
