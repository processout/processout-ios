//
//  POApplePayTokenizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.09.2024.
//

import PassKit

/// Apple Pay tokenization request.
public struct POApplePayTokenizationRequest {

    /// The payment request to be authorized and tokenized.
    public let paymentRequest: PKPaymentRequest

    /// The user-selected billing address for this transaction. This overrides the
    /// billing address from `PKPayment`.
    public let contact: POContact?

    /// Additional metadata.
    public let metadata: [String: String]?

    /// Initializes a new tokenization request.
    /// - Parameters:
    ///   - paymentRequest: The payment request (must not be modified after initialization).
    ///   - contact: Optional user-selected billing address.
    ///   - metadata: Optional additional metadata.
    public init(paymentRequest: PKPaymentRequest, contact: POContact? = nil, metadata: [String: String]? = nil) {
        self.paymentRequest = paymentRequest
        self.contact = contact
        self.metadata = metadata
    }
}

@available(*, unavailable)
extension POApplePayTokenizationRequest: Sendable { }
