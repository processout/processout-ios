//
//  PONativeAlternativePaymentConfirmation.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import Foundation

/// Configuration specific to native APM payment confirmation.
public struct PONativeAlternativePaymentConfirmationConfiguration { // swiftlint:disable:this type_name

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    public let waitsConfirmation: Bool

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Default timeout is 3 minutes while maximum value is 15 minutes.
    public let timeout: TimeInterval

    /// A delay before showing progress indicator during payment confirmation.
    public let showProgressIndicatorAfter: TimeInterval?

    /// Boolean value indicating whether gateway information (such as name/logo) should stay hidden
    /// during payment confirmation even if more specific payment provider details are not available.
    /// Default value is `false`.
    public let hideGatewayDetails: Bool

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    public let secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction?

    /// Creates configuration instance.
    public init(
        waitsConfirmation: Bool = true,
        timeout: TimeInterval = 180,
        showProgressIndicatorAfter: TimeInterval? = nil,
        hideGatewayDetails: Bool = false,
        secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction? = nil
    ) {
        self.waitsConfirmation = waitsConfirmation
        self.timeout = timeout
        self.showProgressIndicatorAfter = showProgressIndicatorAfter
        self.hideGatewayDetails = hideGatewayDetails
        self.secondaryAction = secondaryAction
    }
}
