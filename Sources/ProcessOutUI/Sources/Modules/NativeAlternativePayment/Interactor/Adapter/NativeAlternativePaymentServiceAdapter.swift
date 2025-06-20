//
//  NativeAlternativePaymentServiceAdapter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

protocol NativeAlternativePaymentServiceAdapter {

    func continuePayment(
        with request: NativeAlternativePaymentServiceAdapterRequest,
    ) async throws -> NativeAlternativePaymentServiceAdapterResponse

    func expectPaymentCompletion(
        with request: NativeAlternativePaymentServiceAdapterRequest
    ) async throws -> NativeAlternativePaymentServiceAdapterResponse
}
