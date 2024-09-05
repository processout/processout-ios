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

    /// The user-selected billing address for this transaction. You can set
    /// this value to override billing address value from `PKPayment`.
    public let contact: POContact?

    /// Additional matadata.
    public let metadata: [String: String]?

    public init(paymentRequest: PKPaymentRequest, contact: POContact? = nil, metadata: [String: String]? = nil) {
        self.paymentRequest = paymentRequest
        self.contact = contact
        self.metadata = metadata
    }
}
