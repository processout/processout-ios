//
//  LocalizedStringResource+CardPayment.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation

// swiftlint:disable nesting

extension LocalizedStringResource {

    enum CardPayment {

        /// Title.
        static let title = LocalizedStringResource("card-payment.title")

        enum Invoice {

            /// Title.
            static let title = LocalizedStringResource("card-payment.invoice")

            /// Invoice name.
            static let name = LocalizedStringResource("card-payment.invoice-name")

            /// Amount.
            static let amount = LocalizedStringResource("card-payment.invoice-amount")

            /// Currency code.
            static let currency = LocalizedStringResource("card-payment.invoice-currency")
        }

        /// 3DS service.
        static let threeDSService = LocalizedStringResource("card-payment.3ds-service")

        /// Continue button.
        static let pay = LocalizedStringResource("card-payment.pay")

        /// Success message.
        static let successMessage = LocalizedStringResource("card-payment.success-message")

        /// Error message.
        static let errorMessage = LocalizedStringResource("card-payment.error-message")
    }
}

// swiftlint:enable nesting
