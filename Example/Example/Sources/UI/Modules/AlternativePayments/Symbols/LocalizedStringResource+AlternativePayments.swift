//
//  LocalizedStringResource+AlternativePayments.swift
//  Example
//
//  Created by Andrii Vysotskyi on 20.08.2024.
//

// swiftlint:disable nesting

import Foundation

extension LocalizedStringResource {

    enum AlternativePayments {

        /// Title.
        static let title = LocalizedStringResource("alternative-payments.title")

        /// Gateway settings.
        static let gateway = LocalizedStringResource("alternative-payments.gateway")

        /// Selected gateway configuration.
        static let gatewayConfiguration = LocalizedStringResource("alternative-payments.gateway-configuration")

        enum Filter {

            /// Filter title.
            static let title = LocalizedStringResource("alternative-payments.filter")

            /// All filter.
            static let all = LocalizedStringResource("alternative-payments.filter.all")

            /// Tokenizable filter.
            static let tokenizable = LocalizedStringResource("alternative-payments.filter.tokenizable")

            /// Native filter.
            static let native = LocalizedStringResource("alternative-payments.filter.native")
        }

        /// Native payment preference.
        static let nativePreference = LocalizedStringResource("alternative-payments.native-preference")

        /// Generic error message.
        static let errorMessage = LocalizedStringResource("alternative-payments.error-message")

        /// Success message.
        static let successMessage = LocalizedStringResource(
            "alternative-payments.success-message-\(placeholder: .object)-\(placeholder: .object)"
        )

        /// Pay button.
        static let pay = LocalizedStringResource("alternative-payments.pay")
    }
}

// swiftlint:enable nesting
