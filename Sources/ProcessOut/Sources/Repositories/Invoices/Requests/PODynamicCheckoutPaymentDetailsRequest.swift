//
//  PODynamicCheckoutPaymentDetailsRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.03.2024.
//

import Foundation

public struct PODynamicCheckoutPaymentDetailsRequest {

    /// Invoice identifier.
    public let invoiceId: String

    /// Creates request instance.
    public init(invoiceId: String) {
        self.invoiceId = invoiceId
    }
}
