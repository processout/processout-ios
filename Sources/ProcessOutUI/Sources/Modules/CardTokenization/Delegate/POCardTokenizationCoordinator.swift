//
//  POCardTokenizationCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import Foundation

public protocol POCardTokenizationCoordinator: AnyObject {

    /// Tokenization state.
    var tokenizationState: POCardTokenizationState { get }

    /// Attempts to submit current form.
    @_spi(PO) func tokenize()

    /// Cancells payment if possible.
    @_spi(PO) func cancel()
}
