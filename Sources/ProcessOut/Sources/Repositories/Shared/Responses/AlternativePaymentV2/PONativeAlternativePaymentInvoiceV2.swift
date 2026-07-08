//
//  PONativeAlternativePaymentInvoiceV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.07.2025.
//

import Foundation

/// Native alternative payment invoice information.
public struct PONativeAlternativePaymentInvoiceV2: Sendable, Decodable {

    /// String value that uniquely identifies this invoice.
    public let id: POInvoice.ID

    /// Invoice amount.
    @POImmutableStringCodableDecimal
    public var amount: Decimal

    /// Invoice currency.
    public let currency: String
}
