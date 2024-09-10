//
//  DynamicCheckoutViewModelState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation
import ProcessOut
@_spi(PO) import ProcessOutUI

struct DynamicCheckoutViewModelState {

    struct DynamicCheckout: Identifiable {

        let id: String

        /// Configuration.
        let configuration: PODynamicCheckoutConfiguration

        /// Delegate.
        unowned let delegate: PODynamicCheckoutDelegate

        /// Completion.
        let completion: (Result<Void, POFailure>) -> Void
    }

    /// Invoice details.
    var invoice = InvoiceViewModel()

    /// Dynamic checkout.
    var dynamicCheckout: DynamicCheckout?

    /// Message.
    var message: MessageViewModel?
}
