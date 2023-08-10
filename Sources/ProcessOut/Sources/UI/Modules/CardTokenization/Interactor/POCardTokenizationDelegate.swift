//
//  POCardTokenizationDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.08.2023.
//

@_spi(PO)
public protocol POCardTokenizationDelegate: AnyObject {

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token.
    /// Default implementation does nothing.
    func processTokenizedCard(card: POCard, completion: (Result<POCardTokenizationProcessAction?, Error>) -> Void)
}

extension POCardTokenizationDelegate {

    // swiftlint:disable:next line_length
    public func processTokenizedCard(card: POCard, completion: (Result<POCardTokenizationProcessAction?, Error>) -> Void) {
        completion(.success(nil))
    }
}
