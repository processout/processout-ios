//
//  POCardTokenizationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

/// Card details that should be tokenized.
public struct POCardTokenizationRequest: Encodable {

    /// Number of the card.
    public let number: String

    /// Expiry month of the card.
    public let expMonth: Int

    /// Expiry year of the card.
    public let expYear: Int

    /// Card Verification Code of the card.
    public let cvc: String?

    /// Name of cardholder.
    public let name: String?

    /// Information of cardholder.
    public let contact: POContact?

    /// Preferred scheme defined by the Customer.
    public let preferredScheme: String?

    /// Metadata related to the card.
    public let metadata: [String: String]?

    public init(
        number: String,
        expMonth: Int,
        expYear: Int,
        cvc: String? = nil,
        name: String? = nil,
        contact: POContact? = nil,
        preferredScheme: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.number = number
        self.expMonth = expMonth
        self.expYear = expYear
        self.cvc = cvc
        self.name = name
        self.contact = contact
        self.preferredScheme = preferredScheme
        self.metadata = metadata
    }
}
