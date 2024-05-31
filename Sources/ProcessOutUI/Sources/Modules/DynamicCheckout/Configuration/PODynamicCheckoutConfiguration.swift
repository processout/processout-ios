//
//  PODynamicCheckoutConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit

/// Dynamic checkout configuration.
public struct PODynamicCheckoutConfiguration {

    public struct CaptureSuccess {

        /// Custom success message to display user when payment completes.
        public let message: String?

        /// Defines for how long implementation delays calling completion in case of success.
        public let duration: TimeInterval

        /// Creates configuration instance.
        public init(message: String? = nil, duration: TimeInterval = 3) {
            self.message = message
            self.duration = duration
        }
    }

    public struct CancelButton {

        /// Cancel button title.
        public let title: String?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(title: String? = nil, confirmation: POConfirmationDialogConfiguration? = nil) {
            self.title = title
            self.confirmation = confirmation
        }
    }

    /// Invoice ID to use to initiate a payment.
    public let invoiceId: String

    /// Card collection configuration.
    public let card: PODynamicCheckoutCardConfiguration

    /// Alternative payment method configuration.
    public let alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration

    /// PassKit payment button type.
    public let passKitPaymentButtonType: PKPaymentButtonType

    /// Primary action text, such as "Submit".
    public let primaryButtonTitle: String?

    /// Cancel action. To remove button use `nil`.
    public let cancelButton: CancelButton?

    /// Determines whether to enable skipping payment list step when there is only
    /// one non-instant payment method. Default value: `true`.
    public let allowsSkippingPaymentList: Bool

    /// Capture success screen configuration. In order to avoid showing success screen to user pass `nil`.
    public let captureSuccess: CaptureSuccess?

    /// Creates configuration instance.
    public init(
        invoiceId: String,
        card: PODynamicCheckoutCardConfiguration = .init(),
        alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration = .init(),
        passKitPaymentButtonType: PKPaymentButtonType = .plain,
        primaryButtonTitle: String? = nil,
        cancelButton: CancelButton? = nil,
        allowsSkippingPaymentList: Bool,
        captureSuccess: CaptureSuccess? = .init()
    ) {
        self.invoiceId = invoiceId
        self.card = card
        self.alternativePayment = alternativePayment
        self.passKitPaymentButtonType = passKitPaymentButtonType
        self.primaryButtonTitle = primaryButtonTitle
        self.cancelButton = cancelButton
        self.allowsSkippingPaymentList = allowsSkippingPaymentList
        self.captureSuccess = captureSuccess
    }
}
