//
//  POApplePayCardTokenizationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

import Foundation
import PassKit

public struct POApplePayCardTokenizationRequest {

    /// Payment information.
    public let payment: PKPayment

    /// Contact information.
    public let contact: POContact?

    /// Additional matadata.
    public let metadata: [String: AnyEncodable]?

    public init(
        payment: PKPayment,
        contact: POContact? = nil,
        metadata: [String: AnyEncodable]? = nil
    ) {
        self.payment = payment
        self.contact = contact
        self.metadata = metadata
    }
}
