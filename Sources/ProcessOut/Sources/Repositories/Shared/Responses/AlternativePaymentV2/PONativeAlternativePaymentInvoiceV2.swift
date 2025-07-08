//
//  PONativeAlternativePaymentInvoiceV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.07.2025.
//

import Foundation

/// Native alternative payment invoice information.
public struct PONativeAlternativePaymentInvoiceV2: Sendable, Decodable {

    /// Invoice amount.
    @POImmutableStringCodableDecimal
    public var amount: Decimal

    /// Invoice currency.
    public let currency: String
}
