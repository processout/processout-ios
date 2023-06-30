//
//  PONativeAlternativePaymentMethodParameterValues.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

/// Native alternative payment parameter values.
public struct PONativeAlternativePaymentMethodParameterValues: Decodable {

    /// Message.
    public let message: String?

    /// Customer action message markdown that should be used to explain user how to proceed with payment. Currently
    /// it will be set only when payment state is `PENDING_CAPTURE`.
    public let customerActionMessage: String?
}
