//
//  POCardTokenizationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

/// Card details that should be tokenized.
public struct POCardTokenizationRequest: Codable, Sendable {

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
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var preferredScheme: String?

    /// Metadata related to the card.
    public let metadata: [String: String]?

    /// Customer's locale identifier override.
    @POExcludedEncodable
    public private(set) var localeIdentifier: String?

    public init(
        number: String,
        expMonth: Int,
        expYear: Int,
        cvc: String? = nil,
        name: String? = nil,
        contact: POContact? = nil,
        preferredScheme: String? = nil,
        metadata: [String: String]? = nil,
        localeIdentifier: String? = nil,
    ) {
        self.number = number
        self.expMonth = expMonth
        self.expYear = expYear
        self.cvc = cvc
        self.name = name
        self.contact = contact
        self._preferredScheme = .init(wrappedValue: preferredScheme)
        self.metadata = metadata
        self._localeIdentifier = .init(wrappedValue: localeIdentifier)
    }
}
