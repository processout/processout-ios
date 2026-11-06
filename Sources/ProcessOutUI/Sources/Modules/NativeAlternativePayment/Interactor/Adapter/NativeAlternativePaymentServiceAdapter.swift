//
//  NativeAlternativePaymentServiceAdapter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

@_spi(PO) import ProcessOut

protocol NativeAlternativePaymentServiceAdapter {

    func continuePayment(
        with request: NativeAlternativePaymentServiceAdapterRequest
    ) async throws(POFailure) -> NativeAlternativePaymentServiceAdapterResponse

    func expectPaymentCompletion(
        with request: NativeAlternativePaymentServiceAdapterRequest
    ) async throws(POFailure) -> NativeAlternativePaymentServiceAdapterResponse

    func resolveUrl(
        with request: PONativeAlternativePaymentUrlResolutionRequestV2
    ) async throws(POFailure) -> PONativeAlternativePaymentUrlResolutionResponseV2
}
