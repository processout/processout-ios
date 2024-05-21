//
//  PONativeAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Foundation
import ProcessOut

/// A configuration object that defines how a native alternative payment view content.
/// Use `nil` to indicate that default value should be used.
public struct PONativeAlternativePaymentConfiguration {

    public enum SecondaryAction {

        /// Cancel action.
        ///
        /// - Parameters:
        ///   - title: Action title. Pass `nil` title to use default value.
        ///   - disabledFor: By default user can interact with action immediately after it becomes visible, it is
        ///   possible to make it initialy disabled for given amount of time.
        ///   - confirmation: When property is set implementation asks user to confirm cancel.
        case cancel(
            title: String? = nil, disabledFor: TimeInterval = 0, confirmation: POConfirmationDialogConfiguration? = nil
        )
    }

    /// Invoice that should be authorized/captured.
    public let invoiceId: String

    /// Gateway configuration id that should be used to initiate native alternative payment.
    public let gatewayConfigurationId: String

    /// Custom title.
    public let title: String?

    /// Custom success message to display user when payment completes.
    public let successMessage: String?

    /// Primary action text, such as "Pay".
    public let primaryActionTitle: String?

    /// Secondary action. To remove secondary action use `nil`, this is default behaviour.
    public let secondaryAction: SecondaryAction?

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    public let skipSuccessScreen: Bool

    /// Payment confirmation configuration.
    public let paymentConfirmation: PONativeAlternativePaymentConfirmationConfiguration

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    @available(*, deprecated, renamed: "paymentConfirmation.waitsConfirmation")
    public var waitsPaymentConfirmation: Bool {
        paymentConfirmation.waitsConfirmation
    }

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Default timeout is 3 minutes while maximum value is 15 minutes.
    @available(*, deprecated, renamed: "paymentConfirmation.timeout")
    public var paymentConfirmationTimeout: TimeInterval {
        paymentConfirmation.timeout
    }

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    @available(*, deprecated, renamed: "paymentConfirmation.secondaryAction")
    public var paymentConfirmationSecondaryAction: SecondaryAction? {
        paymentConfirmation.secondaryAction
    }

    /// Creates configuration instance.
    @available(*, deprecated)
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        successMessage: String? = nil,
        primaryActionTitle: String? = nil,
        secondaryAction: SecondaryAction? = nil,
        inlineSingleSelectValuesLimit: Int = 5,
        skipSuccessScreen: Bool = false,
        waitsPaymentConfirmation: Bool = true,
        paymentConfirmationTimeout: TimeInterval = 180,
        paymentConfirmationSecondaryAction: SecondaryAction? = nil
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.successMessage = successMessage
        self.primaryActionTitle = primaryActionTitle
        self.secondaryAction = secondaryAction
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.skipSuccessScreen = skipSuccessScreen
        self.paymentConfirmation = .init(
            waitsConfirmation: waitsPaymentConfirmation,
            timeout: paymentConfirmationTimeout,
            secondaryAction: paymentConfirmationSecondaryAction
        )
    }

    /// Creates configuration instance.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        successMessage: String? = nil,
        primaryActionTitle: String? = nil,
        secondaryAction: SecondaryAction? = nil,
        inlineSingleSelectValuesLimit: Int = 5,
        skipSuccessScreen: Bool = false,
        paymentConfirmation: PONativeAlternativePaymentConfirmationConfiguration = .init()
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.successMessage = successMessage
        self.primaryActionTitle = primaryActionTitle
        self.secondaryAction = secondaryAction
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.skipSuccessScreen = skipSuccessScreen
        self.paymentConfirmation = paymentConfirmation
    }
}
