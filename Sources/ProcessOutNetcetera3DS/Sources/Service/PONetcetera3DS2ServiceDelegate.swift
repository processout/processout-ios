//
//  PONetcetera3DS2ServiceDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import ProcessOut
import ThreeDS_SDK

public protocol PONetcetera3DS2ServiceDelegate: AnyObject, Sendable {

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and returns `true`.
    @MainActor
    func netcetera3DS2Service(
        _ service: PONetcetera3DS2Service, shouldContinueWith warnings: [Warning]
    ) async -> Bool

    /// Notifies the delegate that a 3DS challenge is about to be performed using the specified view controller
    /// as the presentation context.
    ///
    /// The delegate may assign a new value to the `viewController` parameter. If value remains `nil`
    /// after this method returns, the challenge will fail.
    ///
    /// - Parameter viewController: The default presentation context for the challenge.
    @MainActor
    func netcetera3DS2Service(
        _ service: PONetcetera3DS2Service, willPerformChallengeOn viewController: inout UIViewController?
    ) async
}
