//
//  POInvoiceRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.04.2024.
//

/// Request to get single invoice details.
public struct POInvoiceRequest: Sendable, Codable {

    public struct ExpandedProperty: Hashable, Sendable, Codable {

        /// Property name.
        let rawValue: String
    }

    /// Requested invoice ID.
    public let invoiceId: String

    /// A secret key associated with the client making the request.
    ///
    /// This key ensures that the payment methods saved by the customer are
    /// included in the response if the invoice has an assigned customerID.
    public let clientSecret: String?

    /// Expanded properties.
    public let expand: Set<ExpandedProperty>

    /// Boolean value indicating whether invoice should be requested with private
    /// key attached to underlying request.
    @_spi(PO)
    public var attachPrivateKey: Bool

    /// Creates request instance.
    public init(invoiceId: String, clientSecret: String? = nil, expand: Set<ExpandedProperty> = []) {
        self.invoiceId = invoiceId
        self.clientSecret = clientSecret
        self.expand = expand
        self.attachPrivateKey = false
    }

    /// Creates request instance.
    @_spi(PO)
    public init(
        invoiceId: String, clientSecret: String? = nil, expand: Set<ExpandedProperty> = [], attachPrivateKey: Bool
    ) {
        self.invoiceId = invoiceId
        self.clientSecret = clientSecret
        self.expand = expand
        self.attachPrivateKey = attachPrivateKey
    }
}

extension POInvoiceRequest.ExpandedProperty {

    /// Expands transaction.
    public static let transaction = Self(rawValue: "transaction")

    /// Expands invoice payment methods.
    public static let paymentMethods = Self(rawValue: "payment_methods")
}

extension POInvoiceRequest {

    @_spi(PO)
    public func replacing(expand: Set<ExpandedProperty>) -> Self {
        let updatedRequest = POInvoiceRequest(
            invoiceId: self.invoiceId,
            clientSecret: self.clientSecret,
            expand: expand,
            attachPrivateKey: self.attachPrivateKey
        )
        return updatedRequest
    }
}
