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

        /// Available features.
        static let availableFeatures = LocalizedStringResource("features.available-features")

        /// Alternative payment.
        static let alternativePayment = LocalizedStringResource("features.alternative-payment")

        /// Card payment.
        static let cardPayment = LocalizedStringResource("features.card-payment")

        /// Card scanner.
        static let cardScanner = LocalizedStringResource("features.card-scanner")

        /// Dynamic checkout.
        static let dynamicCheckout = LocalizedStringResource("features.dynamic-checkout")

        /// Saved payment methods
        static let savedPaymentMethods = LocalizedStringResource("features.saved-payment-methods")

        /// ApplePay.
        static let applePay = LocalizedStringResource("features.apple-pay")

        /// App configuration.
        static let applicationConfiguration = LocalizedStringResource("features.application-configuration")
    }
}
