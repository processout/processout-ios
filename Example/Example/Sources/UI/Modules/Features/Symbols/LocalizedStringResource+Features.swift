//
//  LocalizedStringResource+Features.swift
//  Example
//
//  Created by Andrii Vysotskyi on 20.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum Features {

        /// Title.
        static let title = LocalizedStringResource("features.title")

        /// Native alternative payment.
        static let nativeAlternativePayment = LocalizedStringResource("features.native-alternative-payment")

        /// Alternative payment.
        static let alternativePayment = LocalizedStringResource("features.alternative-payment")

        /// ApplePay.
        static let applePay = LocalizedStringResource("features.apple-pay")

        /// Card payment.
        static let cardPayment = LocalizedStringResource("features.card-payment")

        /// CKO based card payment.
        static let checkoutCardPayment = LocalizedStringResource("features.checkout-card-payment")

        /// Dynamic checkout.
        static let dynamicCheckout = LocalizedStringResource("features.dynamic-checkout")

        /// Error.
        static let error = LocalizedStringResource("features.error-\(placeholder: .object)")

        /// Generic error.
        static let genericError = LocalizedStringResource("features.generic-error")

        /// Success message.
        static let successMessage = LocalizedStringResource("features.success-message")

        /// Continue button.
        static let `continue` = LocalizedStringResource("features.continue")
    }
}
