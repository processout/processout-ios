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

    /// Payment confirmation configuration.
    public struct PaymentConfirmation {

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

        /// Button that could be optionally presented to user during payment confirmation stage. To remove it
        /// use `nil`, this is default behaviour.
        public let cancelButton: CancelButton?

        /// Creates configuration instance.
        public init(
            waitsConfirmation: Bool = true,
            timeout: TimeInterval = 180,
            showProgressIndicatorAfter: TimeInterval? = nil,
            hideGatewayDetails: Bool = false,
            cancelButton: CancelButton? = nil
        ) {
            self.waitsConfirmation = waitsConfirmation
            self.timeout = timeout
            self.showProgressIndicatorAfter = showProgressIndicatorAfter
            self.hideGatewayDetails = hideGatewayDetails
            self.cancelButton = cancelButton
        }
    }

    public struct CancelButton: Sendable {

        /// Cancel button title. Use `nil` for default title.
        public let title: String?

        /// By default user can interact with action immediately after it becomes visible, it is
        /// possible to make it initially disabled for given amount of time.
        public let disabledFor: TimeInterval

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(
            title: String? = nil,
            disabledFor: TimeInterval = 0,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.disabledFor = disabledFor
            self.confirmation = confirmation
        }
    }

    /// Invoice that should be authorized/captured.
    public let invoiceId: String

    /// Gateway configuration id that should be used to initiate native alternative payment.
    public let gatewayConfigurationId: String

    /// Custom title.
    public let title: String?

    /// A Boolean property that indicates whether the code input should be horizontally centered. This property
    /// is only applicable when there is a single code input. If there are multiple inputs the alignment is always
    /// leading. Default value is `true`.
    public let shouldHorizontallyCenterCodeInput: Bool

    /// Custom success message **markdown** to display user when payment completes.
    public let successMessage: String?

    /// Primary button text, such as "Pay".
    public let primaryButtonTitle: String?

    /// Cancel button. To remove cancel button use `nil`, this is default behaviour.
    public let cancelButton: CancelButton?

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    public let skipSuccessScreen: Bool

    /// Payment confirmation configuration.
    public let paymentConfirmation: PaymentConfirmation

    /// Creates configuration instance.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        shouldHorizontallyCenterCodeInput: Bool = true,
        successMessage: String? = nil,
        primaryButtonTitle: String? = nil,
        cancelButton: CancelButton? = nil,
        inlineSingleSelectValuesLimit: Int = 5,
        skipSuccessScreen: Bool = false,
        paymentConfirmation: PaymentConfirmation = .init()
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.shouldHorizontallyCenterCodeInput = shouldHorizontallyCenterCodeInput
        self.successMessage = successMessage
        self.primaryButtonTitle = primaryButtonTitle
        self.cancelButton = cancelButton
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.skipSuccessScreen = skipSuccessScreen
        self.paymentConfirmation = paymentConfirmation
    }
}
