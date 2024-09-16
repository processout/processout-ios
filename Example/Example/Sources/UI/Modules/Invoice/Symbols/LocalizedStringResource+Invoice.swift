//
//  LocalizedStringResource+Invoice.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum Invoice {

        /// Invoice ID.
        static let id = LocalizedStringResource("invoice.id")

        /// Title.
        static let title = LocalizedStringResource("invoice.title")

        /// Invoice name.
        static let name = LocalizedStringResource("invoice.name")

        /// Amount.
        static let amount = LocalizedStringResource("invoice.amount")

        /// Currency code.
        static let currency = LocalizedStringResource("invoice.currency-code")
    }
}
