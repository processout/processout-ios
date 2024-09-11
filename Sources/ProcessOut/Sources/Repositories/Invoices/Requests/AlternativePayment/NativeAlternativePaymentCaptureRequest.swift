//
//  NativeAlternativePaymentCaptureRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2022.
//

struct NativeAlternativePaymentCaptureRequest: Encodable, Sendable { // sourcery: AutoCodingKeys

    /// Invoice identifier.
    let invoiceId: String // sourcery:coding: skip

    /// Source must be set to gateway configuration id that was used to initiate native alternative payment.
    let source: String
}
