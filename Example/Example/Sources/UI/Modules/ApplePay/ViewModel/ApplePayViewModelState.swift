//
//  ApplePayViewModelState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation
import ProcessOut
@_spi(PO) import ProcessOutUI

struct ApplePayViewModelState {

    /// Invoice details.
    var invoice = InvoiceViewModel()

    /// Message.
    var message: MessageViewModel?
}
