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
    func tokenize()

    /// Cancells payment if possible.
    func cancel()
}
