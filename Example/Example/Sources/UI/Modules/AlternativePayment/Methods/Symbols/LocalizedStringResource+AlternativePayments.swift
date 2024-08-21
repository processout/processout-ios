//
//  LocalizedStringResource+AlternativePayments.swift
//  Example
//
//  Created by Andrii Vysotskyi on 20.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum AlternativePayments {

        /// Title.
        static let title = LocalizedStringResource("alternative-payments.title")

        /// Error message.
        static let error = LocalizedStringResource("alternative-payments.error-\(placeholder: .object)")

        /// Generic error message.
        static let genericError = LocalizedStringResource("alternative-payments.generic-error")

        /// Continue button.
        static let `continue` = LocalizedStringResource("alternative-payments.continue")
    }
}
