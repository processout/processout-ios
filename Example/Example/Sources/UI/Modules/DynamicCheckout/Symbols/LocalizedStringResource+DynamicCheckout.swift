//
//  LocalizedStringResource+DynamicCheckout.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum DynamicCheckout {

        /// Title.
        static let title = LocalizedStringResource("dynamic-checkout.title")

        /// Continue button.
        static let pay = LocalizedStringResource("dynamic-checkout.pay")

        /// Success message.
        static let successMessage = LocalizedStringResource("dynamic-checkout.success-message-\(placeholder: .object)")

        /// Error message.
        static let errorMessage = LocalizedStringResource("dynamic-checkout.error-message")
    }
}
