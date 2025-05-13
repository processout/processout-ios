//
//  PresentingViewControllerProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import UIKit

enum PresentingViewControllerProvider {

    /// Attempts to find view controller that can modally present other view controller.
    @MainActor
    static func find() -> UIViewController? {
        let rootViewController = UIApplication.shared
            .connectedScenes
            .lazy
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0.windows.first(where: \.isKeyWindow) }
            .first?
            .rootViewController
        var presentingViewController = rootViewController
        while let presented = presentingViewController?.presentedViewController {
            presentingViewController = presented
        }
        return presentingViewController
    }
}
