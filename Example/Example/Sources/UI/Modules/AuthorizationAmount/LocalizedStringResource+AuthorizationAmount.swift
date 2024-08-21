//
//  LocalizedStringResource+AuthorizationAmount.swift
//  Example
//
//  Created by Andrii Vysotskyi on 20.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum AuthorizationAmount {

        /// Message.
        static let message = LocalizedStringResource("authorization-amount.message")

        /// Amount.
        static let amount = LocalizedStringResource("authorization-amount.amount")

        /// Currency code.
        static let currency = LocalizedStringResource("authorization-amount.currency")

        /// Confirm button.
        static let confirm = LocalizedStringResource("authorization-amount.confirm")
    }
}
