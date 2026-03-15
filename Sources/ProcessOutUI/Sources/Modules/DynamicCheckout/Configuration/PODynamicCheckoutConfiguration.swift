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

        /// Button title, such as "Settings". Set `nil` to use default value, or empty string `""` to remove title.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Payment method saving options.
    @MainActor
    public struct Saving {

        /// Initial selection state.
        public let isOnByDefault: Bool

        /// If `true`, saving is enforced and cannot be disabled by the user.
        public let isRequired: Bool

        /// Creates a saving configuration.
        public init(isOnByDefault: Bool = false, isRequired: Bool = false) {
            self.isOnByDefault = isRequired ? true : isOnByDefault
            self.isRequired = isRequired
        }
    }

    /// Payment success configuration.
    @MainActor
    public struct PaymentSuccess {

        /// Custom title to display to user when payment completes.
        public let title: String?

        /// Custom success message to display to user when payment completes.
        public let message: String?

        /// Defines for how long implementation delays calling completion in case of success.
        public let duration: TimeInterval

        /// Creates configuration instance.
        public init(title: String? = nil, message: String? = nil, duration: TimeInterval = 3) {
            self.title = title
            self.message = message
            self.duration = duration
        }
    }

    /// Submit button configuration.
    @MainActor
    public struct SubmitButton {

        /// Button title, such as "Pay". Set `nil` to use default value, or empty string `""` to remove title.
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

        /// Button title. Set `nil` to use default value, or empty string `""` to remove title.
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

    /// Controls the visibility and appearance of the saved payment methods.
    ///
    /// Set this value to `nil` to hide the entire "Express Checkout" section and omit saved
    /// payments from the flow.
    ///
    /// This setting does not affect the availability of other payment options , nor does it affect
    /// whether the user can save a payment method.
    public let expressCheckout: ExpressCheckout?

    /// Card collection configuration.
    public let card: PODynamicCheckoutCardConfiguration

    /// Alternative payment method configuration.
    public let alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration

    /// PassKit payment button type.
    public let passKitPaymentButtonType: PKPaymentButtonType

    /// Saving configuration for supported payment methods.
    ///
    /// When set to `nil` user won't be suggested to save payment method.
    public let saving: Saving?

    /// Determines whether to enable skipping payment list step when there is only
    /// one non-instant payment method. Default value: `true`.
    public let allowsSkippingPaymentList: Bool

    /// Submit button.
    public let submitButton: SubmitButton

    /// Cancel button. To remove button use `nil`.
    public let cancelButton: CancelButton?

    /// Capture success screen configuration. In order to avoid showing success screen to user pass `nil`.
    public let paymentSuccess: PaymentSuccess?

    /// Localization configuration. Defaults to device localization.
    public let localization: LocalizationConfiguration

    /// Creates configuration instance.
    public init(
        invoiceRequest: POInvoiceRequest,
        expressCheckout: ExpressCheckout? = .init(),
        card: PODynamicCheckoutCardConfiguration = .init(),
        alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration = .init(),
        passKitPaymentButtonType: PKPaymentButtonType = .plain,
        saving: Saving? = .init(),
        allowsSkippingPaymentList: Bool = true,
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = .init(),
        paymentSuccess: PaymentSuccess? = .init(),
        localization: LocalizationConfiguration = .device()
    ) {
        self.invoiceRequest = invoiceRequest
        self.expressCheckout = expressCheckout
        self.card = card
        self.alternativePayment = alternativePayment
        self.passKitPaymentButtonType = passKitPaymentButtonType
        self.saving = saving
        self.allowsSkippingPaymentList = allowsSkippingPaymentList
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.paymentSuccess = paymentSuccess
        self.localization = localization
    }
}
