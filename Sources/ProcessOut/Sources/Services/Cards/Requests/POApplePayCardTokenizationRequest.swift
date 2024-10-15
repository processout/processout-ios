//
//  POApplePayCardTokenizationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

import Foundation
import PassKit

@available(*, deprecated, renamed: "POApplePayPaymentTokenizationRequest")
public typealias POApplePayCardTokenizationRequest = POApplePayPaymentTokenizationRequest

/// Apple Pay payment details.
public struct POApplePayPaymentTokenizationRequest {

    /// Payment information.
    public let payment: PKPayment

    /// Identifies the merchant, as previously agreed with Apple. Must match `PKPaymentRequest/merchantIdentifier`
    /// that was used to produce `PKPayment`.
    public let merchantIdentifier: String?

    /// The user-selected billing address for this transaction. You can set
    /// this value to override billing address value from `PKPayment`.
    public let contact: POContact?

    /// Additional matadata.
    public let metadata: [String: String]?

    public init(
        payment: PKPayment,
        merchantIdentifier: String? = nil,
        contact: POContact? = nil,
        metadata: [String: String]? = nil
    ) {
        self.payment = payment
        self.merchantIdentifier = merchantIdentifier
        self.contact = contact
        self.metadata = metadata
    }
}

@available(*, unavailable)
extension POApplePayPaymentTokenizationRequest: Sendable { }
