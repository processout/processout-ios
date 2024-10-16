//
//  PresentingViewControllerProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.11.2023.
//

import UIKit

enum PresentingViewControllerProvider {

    /// Attempts to find view controller that can modally present other view controller.
    @MainActor
    @preconcurrency
    static func find() -> UIViewController? {
        let rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController
        var presentingViewController = rootViewController
        while let presented = presentingViewController?.presentedViewController {
            presentingViewController = presented
        }
        return presentingViewController
    }
}
