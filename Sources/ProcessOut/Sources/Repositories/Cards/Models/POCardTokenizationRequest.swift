//
//  POCardTokenizationRequest.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

public struct POCardTokenizationRequest: Encodable {
    /// Metada related to the card
    public let metadata: [String: AnyEncodable]?

    /// Number of the card
    public let number: String

    /// Expiry month of the card
    public let expMonth: Int

    /// Expiry year of the card
    public let expYear: Int

    /// Card Verification Code of the card
    public let cvc: String?

    /// Name of cardholder
    public let name: String?

    /// Information of cardholder
    public let contact: POContact?

    public init(
        metadata: [String: AnyEncodable]? = nil,
        number: String,
        expMonth: Int,
        expYear: Int,
        cvc: String? = nil,
        name: String? = nil,
        contact: POContact? = nil
    ) {
        self.metadata = metadata
        self.number = number
        self.expMonth = expMonth
        self.expYear = expYear
        self.cvc = cvc
        self.name = name
        self.contact = contact
    }
}
