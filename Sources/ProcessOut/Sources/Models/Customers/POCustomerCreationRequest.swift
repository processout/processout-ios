//
//  POCustomerCreationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.12.2024.
//

@_spi(PO)
public struct POCustomerCreationRequest: Encodable, Sendable {

    /// First name of the customer.
    public let firstName: String?

    /// Last name of the customer.
    public let lastName: String?

    init(firstName: String? = nil, lastName: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
