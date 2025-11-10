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

    enum AuthenticationService: String, Hashable {

        /// Test service.
        case test

        /// Checkout service.
        case checkout

        /// Netcetera 3DS SDK.
        case netcetera
    }

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

    /// 3DS service.
    var authenticationService = PickerData<AuthenticationService, AuthenticationService>(
        sources: [.test, .checkout, .netcetera], id: \.self, selection: .netcetera
    )

    /// Dynamic checkout.
    var dynamicCheckout: DynamicCheckout?

    /// Message.
    var message: MessageViewModel?
}
