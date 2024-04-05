//
//  NativeAlternativePaymentCaptureRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2022.
//

struct NativeAlternativePaymentCaptureRequest: Encodable {

    /// Invoice identifier.
    @POImmutableExcludedCodable
    var invoiceId: String

    /// Source must be set to gateway configuration id that was used to initiate native alternative payment.
    let source: String

    init(invoiceId: String, source: String) {
        self._invoiceId = .init(value: invoiceId)
        self.source = source
    }
}
