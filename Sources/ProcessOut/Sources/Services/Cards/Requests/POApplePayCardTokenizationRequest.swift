//
//  POApplePayCardTokenizationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

import Foundation
import PassKit

/// Apple pay card details.
public struct POApplePayCardTokenizationRequest {

    /// Payment information.
    public let payment: PKPayment

    /// Identifies the merchant, as previously agreed with Apple. Must match `PKPaymentRequest/merchantIdentifier`
    /// that was used to produce `PKPayment`.
    public let merchantIdentifier: String?

    /// The user-selected billing address for this transaction.
    public let contact: POContact?

    /// The user-selected shipping address for this transaction.
    public let shippingContact: POContact?

    /// Additional matadata.
    public let metadata: [String: String]?

    public init(
        payment: PKPayment,
        merchantIdentifier: String? = nil,
        contact: POContact? = nil,
        shippingContact: POContact? = nil,
        metadata: [String: String]? = nil
    ) {
        self.payment = payment
        self.merchantIdentifier = merchantIdentifier
        self.contact = contact
        self.shippingContact = shippingContact
        self.metadata = metadata
    }
}
