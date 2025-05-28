//
//  PONativeAlternativePaymentDelegateV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

@_spi(PO) import ProcessOut

/// Native alternative payment module delegate definition.
@_spi(PO)
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
        defaultValuesFor parameters: [PONativeAlternativePaymentNextStepV2.SubmitData.Parameter]
    ) async -> [String: PONativeAlternativePaymentAuthorizationRequestV2.Parameter]
}
