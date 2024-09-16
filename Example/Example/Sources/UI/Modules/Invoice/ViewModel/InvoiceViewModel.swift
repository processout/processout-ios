//
//  InvoiceViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import Foundation

struct InvoiceViewModel {

    /// Invoice ID.
    var id: String

    /// Invoice amount.
    var amount: Decimal

    /// Currency code.
    var currencyCode: String
}

extension InvoiceViewModel {

    /// Convenience init to create default view model.
    init() {
        id = ""
        amount = 100
        currencyCode = "USD"
    }
}
