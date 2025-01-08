//
//  StringResource+DynamicCheckout.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

@_spi(PO) import ProcessOut

// swiftlint:disable nesting

extension POStringResource {

    enum DynamicCheckout {

        enum Button {

            /// Submit button title.
            static let pay = POStringResource("dynamic-checkout.pay-button", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("dynamic-checkout.cancel-button", comment: "")
        }

        enum Error {

            /// Indicates that implementation is unable to process payment.
            static let generic = POStringResource("dynamic-checkout.error.generic", comment: "")

            /// Indicates that selected payment method is no longer available.
            static let methodUnavailable = POStringResource("dynamic-checkout.error.method-unavailable", comment: "")
        }

        enum Warning {

            /// APM redirect information.
            static let redirect = POStringResource("dynamic-checkout.redirect-warning", comment: "")
        }

        /// Express checkout section title.
        static let expressCheckout = POStringResource("dynamic-checkout.express-checkout", comment: "")

        /// Save payment method information message.
        static let savePaymentMessage = POStringResource("dynamic-checkout.save-payment-message", comment: "")

        /// Success message.
        static let successMessage = POStringResource("dynamic-checkout.success-message", comment: "")
    }
}

// swiftlint:enable nesting
