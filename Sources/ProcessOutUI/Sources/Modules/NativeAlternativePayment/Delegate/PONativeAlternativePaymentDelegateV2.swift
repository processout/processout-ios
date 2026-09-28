//
//  PONativeAlternativePaymentDelegateV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

import ProcessOut

/// Native alternative payment module delegate definition.
public protocol PONativeAlternativePaymentDelegateV2: AnyObject, Sendable {

    /// Invoked when module emits event.
    @MainActor
    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEventV2)

    /// Method provides an ability to supply default values for given parameters. It is not mandatory
    /// to provide defaults for all parameters.
    ///
    /// - Returns: Dictionary where key is a parameter key, and value is desired default.
    @MainActor
    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentFormV2.Parameter]
    ) async -> [String: PONativeAlternativePaymentParameterValue]

    /// Asks delegate to finalize payment by explicitly advancing it to an authorized and/or captured state
    /// using one of the available actions.
    ///
    /// Method is invoked at most once, either when all customer actions are completed or when payment is
    /// already authorized and could still be captured. In the latter case implementation may return without
    /// advancing payment to leave it authorized.
    @MainActor
    func nativeAlternativePayment(
        finalizeWith request: PONativeAlternativePaymentFinalizeRequestV2
    ) async throws(POFailure)
}

extension PONativeAlternativePaymentDelegateV2 {

    @MainActor
    public func nativeAlternativePayment(
        finalizeWith request: PONativeAlternativePaymentFinalizeRequestV2
    ) async throws(POFailure) {
        assertionFailure("Method must be implemented when manual finalization is used.")
        throw .init(message: "Manual finalization is not implemented.", code: .Mobile.generic)
    }
}
