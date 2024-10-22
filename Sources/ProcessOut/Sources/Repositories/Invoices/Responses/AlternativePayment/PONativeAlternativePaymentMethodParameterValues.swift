//
//  PONativeAlternativePaymentMethodParameterValues.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

import Foundation

/// Native alternative payment parameter values.
public struct PONativeAlternativePaymentMethodParameterValues: Decodable, Sendable {

    /// Message.
    public let message: String?

    /// Customer action message markdown that should be used to explain user how to proceed with payment. Currently
    /// it will be set only when payment state is `PENDING_CAPTURE`.
    public let customerActionMessage: String?

    /// A barcode that represents the customer's action, such as a QR code for payment.
    public let customerActionBarcode: POBarcode?

    /// Payment provider name.
    public let providerName: String?

    /// Payment provider logo URL if available.
    public let providerLogoUrl: URL?
}
