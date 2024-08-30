//
//  InvoiceViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import Foundation

struct InvoiceViewModel {

    /// Invoice name.
    var name: String

    /// Invoice amount.
    var amount: String

    /// Currency code.
    var currencyCode: PickerData<Locale.Currency, String>
}

extension InvoiceViewModel {

    /// Convenience init to create default view model.
    init() {
        self.name = UUID().uuidString
        self.amount = ""
        currencyCode = .init(sources: Locale.Currency.isoCurrencies, id: \.identifier, selection: "USD")
    }
}
