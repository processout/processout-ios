//
//  POInvoice.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.10.2022.
//

import Foundation

/// Invoice details.
public struct POInvoice: Codable, Sendable {

    /// String value that uniquely identifies this invoice.
    public let id: String

    @POImmutableStringCodableDecimal
    public var amount: Decimal

    /// Invoice currency.
    public let currency: String

    /// Application will be redirected to this URL in case of success. Useful for web based operations. 
    public let returnUrl: URL?

    /// Customer ID associated with invoice.
    public let customerId: String?

    /// Dynamic checkout details resolved for specific invoice.
    public let paymentMethods: [PODynamicCheckoutPaymentMethod]?

    /// Client secret.
    @_spi(PO)
    public let clientSecret: String?

    /// Transaction details.
    public let transaction: POTransaction?
}
