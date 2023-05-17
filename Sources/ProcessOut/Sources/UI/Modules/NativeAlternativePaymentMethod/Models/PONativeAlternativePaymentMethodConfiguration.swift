//
//  PONativeAlternativePaymentMethodConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import Foundation

/// A configuration object that defines how a native alternative payment view controller content's.
/// Use `nil` to indicate that default value should be used.
public struct PONativeAlternativePaymentMethodConfiguration {

    public enum SecondaryAction {

        /// Cancel action.
        ///
        /// - Parameters:
        ///   - title: Action title. Pass `nil` title to use default value.
        ///   - disabledFor: By default user can interact with action immediately after it becomes visible, it is
        ///   possible to make it initialy disabled for given amount of time.
        case cancel(title: String? = nil, disabledFor: TimeInterval = 0)
    }

    /// Custom title.
    public let title: String?

    /// Custom success message to display user when payment completes.
    public let successMessage: String?

    /// Primary action text, such as "Pay".
    public let primaryActionTitle: String?

    /// Secondary action. To remove secondary action use `nil`, this is default behaviour.
    public let secondaryAction: SecondaryAction?

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    public let skipSuccessScreen: Bool

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    public let waitsPaymentConfirmation: Bool

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Maximum value is 180 seconds.
    public let paymentConfirmationTimeout: TimeInterval

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    public let paymentConfirmationAction: SecondaryAction?

    public init(
        title: String? = nil,
        successMessage: String? = nil,
        primaryActionTitle: String? = nil,
        secondaryAction: SecondaryAction? = nil,
        skipSuccessScreen: Bool = false,
        waitsPaymentConfirmation: Bool = true,
        paymentConfirmationTimeout: TimeInterval = 180,
        paymentConfirmationAction: SecondaryAction? = nil
    ) {
        self.title = title
        self.successMessage = successMessage
        self.primaryActionTitle = primaryActionTitle
        self.secondaryAction = secondaryAction
        self.skipSuccessScreen = skipSuccessScreen
        self.waitsPaymentConfirmation = waitsPaymentConfirmation
        self.paymentConfirmationTimeout = paymentConfirmationTimeout
        self.paymentConfirmationAction = paymentConfirmationAction
    }
}
