//
//  CardPaymentViewModelState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation
import ProcessOut
import ProcessOutUI

struct CardPaymentViewModelState {

    enum AuthenticationService: String, Hashable {

        /// Test service.
        case test

        /// Checkout service.
        case checkout
    }

    struct Invoice {

        /// Invoice name.
        var name: String = ""

        /// Invoice amount.
        var amount: String = ""

        /// Currency code.
        var currencyCode: PickerData<Locale.Currency, String>
    }

    struct CardTokenization: Identifiable {

        let id: String

        /// Configuration.
        let configuration: POCardTokenizationConfiguration

        /// Delegate.
        weak var delegate: POCardTokenizationDelegate?

        /// Completion.
        let completion: (Result<POCard, POFailure>) -> Void
    }

    /// Invoice details.
    var invoice: Invoice

    /// 3DS service.
    var authenticationService: PickerData<AuthenticationService, AuthenticationService>

    /// Card tokenization.
    var cardTokenization: CardTokenization?
}
