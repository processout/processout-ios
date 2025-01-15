//
//  PODynamicCheckoutConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit
import SwiftUI
import ProcessOut

/// Dynamic checkout configuration.
@_spi(PO)
@MainActor
public struct PODynamicCheckoutConfiguration {

    @MainActor
    public struct ExpressCheckout {

        /// Express checkout section title.
        public let title: String?

        /// Settings button configuration.
        public let settingsButton: ExpressCheckoutSettingsButton?

        public init(title: String? = nil, settingsButton: ExpressCheckoutSettingsButton? = .init()) {
            self.title = title
            self.settingsButton = settingsButton
        }
    }

    @MainActor
    public struct ExpressCheckoutSettingsButton {

        /// Button title, such as "Settings". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Payment success configuration.
    @MainActor
    public struct PaymentSuccess {

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

    /// Submit button configuration.
    @MainActor
    public struct SubmitButton {

        /// Button title, such as "Pay". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Cancel button configuration.
    @MainActor
    public struct CancelButton {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init<Icon: View>(
            title: String? = nil, icon: Icon? = AnyView?.none, confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.confirmation = confirmation
        }
    }

    /// Request to fetch invoice to initiate a payment.
    public let invoiceRequest: POInvoiceRequest

    /// Express checkout section configuration.
    public let expressCheckout: ExpressCheckout

    /// Card collection configuration.
    public let card: PODynamicCheckoutCardConfiguration

    /// Alternative payment method configuration.
    public let alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration

    /// PassKit payment button type.
    public let passKitPaymentButtonType: PKPaymentButtonType

    /// Determines whether to enable skipping payment list step when there is only
    /// one non-instant payment method. Default value: `true`.
    public let allowsSkippingPaymentList: Bool

    /// Submit button.
    public let submitButton: SubmitButton

    /// Cancel button. To remove button use `nil`.
    public let cancelButton: CancelButton?

    /// Capture success screen configuration. In order to avoid showing success screen to user pass `nil`.
    public let paymentSuccess: PaymentSuccess?

    // Creates configuration instance.
    public init(
        invoiceRequest: POInvoiceRequest,
        expressCheckout: ExpressCheckout = .default,
        card: PODynamicCheckoutCardConfiguration = .default,
        alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration = .default,
        passKitPaymentButtonType: PKPaymentButtonType = .plain,
        allowsSkippingPaymentList: Bool = true,
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = .init(),
        paymentSuccess: PaymentSuccess? = .init()
    ) {
        self.invoiceRequest = invoiceRequest
        self.expressCheckout = expressCheckout
        self.card = card
        self.alternativePayment = alternativePayment
        self.passKitPaymentButtonType = passKitPaymentButtonType
        self.allowsSkippingPaymentList = allowsSkippingPaymentList
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.paymentSuccess = paymentSuccess
    }
}

extension PODynamicCheckoutConfiguration.ExpressCheckout {

    /// Default configuration.
    /// - NOTE: Only used to fix compatibility issue with Xcode 15.
    @inlinable
    @MainActor
    static var `default`: PODynamicCheckoutConfiguration.ExpressCheckout {
        PODynamicCheckoutConfiguration.ExpressCheckout()
    }
}
