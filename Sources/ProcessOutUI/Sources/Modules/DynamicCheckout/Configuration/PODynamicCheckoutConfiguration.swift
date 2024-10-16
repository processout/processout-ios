//
//  PODynamicCheckoutConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit
import ProcessOut

/// Dynamic checkout configuration.
@_spi(PO)
public struct PODynamicCheckoutConfiguration: Sendable {

    public struct PaymentSuccess: Sendable {

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

    public struct CancelButton: Sendable {

        /// Cancel button title.
        public let title: String?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(title: String? = nil, confirmation: POConfirmationDialogConfiguration? = nil) {
            self.title = title
            self.confirmation = confirmation
        }
    }

    /// Request to fetch invoice to initiate a payment.
    public let invoiceRequest: POInvoiceRequest

    /// Card collection configuration.
    public let card: PODynamicCheckoutCardConfiguration

    /// Alternative payment method configuration.
    public let alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration

    /// PassKit payment button type.
    public let passKitPaymentButtonType: PKPaymentButtonType

    /// Primary button text, such as "Submit".
    public let submitButtonTitle: String?

    /// Cancel button. To remove button use `nil`.
    public let cancelButton: CancelButton?

    /// Determines whether to enable skipping payment list step when there is only
    /// one non-instant payment method. Default value: `true`.
    public let allowsSkippingPaymentList: Bool

    /// Capture success screen configuration. In order to avoid showing success screen to user pass `nil`.
    public let paymentSuccess: PaymentSuccess?

    /// Creates configuration instance.
    public init(
        invoiceRequest: POInvoiceRequest,
        card: PODynamicCheckoutCardConfiguration = .init(),
        alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration = .init(),
        passKitPaymentButtonType: PKPaymentButtonType = .plain,
        submitButtonTitle: String? = nil,
        cancelButton: CancelButton? = nil,
        allowsSkippingPaymentList: Bool = true,
        paymentSuccess: PaymentSuccess? = .init()
    ) {
        self.invoiceRequest = invoiceRequest
        self.card = card
        self.alternativePayment = alternativePayment
        self.passKitPaymentButtonType = passKitPaymentButtonType
        self.submitButtonTitle = submitButtonTitle
        self.cancelButton = cancelButton
        self.allowsSkippingPaymentList = allowsSkippingPaymentList
        self.paymentSuccess = paymentSuccess
    }
}
