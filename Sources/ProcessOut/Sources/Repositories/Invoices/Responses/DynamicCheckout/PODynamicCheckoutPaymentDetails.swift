//
//  PODynamicCheckoutPaymentDetails.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

/// Dynamic checkout details resolved for specific invoice..
public struct PODynamicCheckoutPaymentDetails: Decodable {

    /// Invoice details.
    public let invoice: PODynamicCheckoutInvoice

    /// Resolved payment methods.
    public let paymentMethods: [PODynamicCheckoutPaymentMethod]
}
