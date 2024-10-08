//
//  LocalizedStringResource+ApplePay.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum ApplePay {

        /// Title.
        static let title = LocalizedStringResource("apple-pay.title")

        /// Pay button.
        static let pay = LocalizedStringResource("apple-pay.pay")

        /// Success message.
        static let successMessage = LocalizedStringResource(
            "apple-pay.success-message-\(placeholder: .object)-\(placeholder: .object)"
        )

        /// Error message.
        static let errorMessage = LocalizedStringResource("apple-pay.error-message")
    }
}
