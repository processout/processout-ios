//
//  POContact.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 26/10/2022.
//

import Foundation

/// Cardholder information.
public struct POContact: Encodable, Sendable {

    /// First line of cardholder’s address.
    public let address1: String?

    /// Second line of cardholder’s address.
    public let address2: String?

    /// City of cardholder’s address.
    public let city: String?

    /// State or county of cardholder’s address.
    public let state: String?

    /// ZIP code of cardholder’s address.
    public let zip: String?

    /// Country code of the delivery address.
    public let countryCode: String?

    public init(
        address1: String? = nil,
        address2: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zip: String? = nil,
        countryCode: String? = nil
    ) {
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.zip = zip
        self.countryCode = countryCode
    }
}
