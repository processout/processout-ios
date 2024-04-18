//
//  POInvoice.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.10.2022.
//

import Foundation

public struct POInvoice: Decodable {

    /// String value that uniquely identifies this invoice.
    public let id: String

    @POImmutableStringCodableDecimal
    public var amount: Decimal

    /// Invoice currency.
    public let currency: String

    /// Application will be redirected to this URL in case of success. Useful for web based operations. 
    public let returnUrl: URL?

    /// Dynamic checkout details resolved for specific invoice.
    public let paymentMethods: [PODynamicCheckoutPaymentMethod]?
}
