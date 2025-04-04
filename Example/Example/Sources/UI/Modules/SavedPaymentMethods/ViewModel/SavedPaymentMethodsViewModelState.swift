//
//  SavedPaymentMethodsViewModelState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 06.01.2025.
//

import Foundation
import ProcessOut
import ProcessOutUI

struct SavedPaymentMethodsViewModelState {

    struct SavedPaymentMethods: Identifiable {

        let id: String

        /// Configuration.
        let configuration: POSavedPaymentMethodsConfiguration

        /// Completion.
        let completion: (Result<Void, POFailure>) -> Void
    }

    /// Invoice details.
    var invoice = InvoiceViewModel()

    /// Saved payment methods.
    var savedPaymentMethods: SavedPaymentMethods?

    /// Message.
    var message: MessageViewModel?
}
