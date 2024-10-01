//
//  PONativeAlternativePaymentMethodDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2023.
//

/// Native alternative payment module delegate definition.
public protocol PONativeAlternativePaymentMethodDelegate: AnyObject {

    /// Invoked when module emits event.
    func nativeAlternativePaymentMethodDidEmitEvent(_ event: PONativeAlternativePaymentMethodEvent)

    /// Method provides an ability to supply default values for given parameters. Completion expects dictionary
    /// where key is a parameter key, and value is desired default. It is not mandatory to provide defaults for
    /// all parameters.
    /// - NOTE: completion must be called on `main` thread.
    func nativeAlternativePaymentMethodDefaultValues(
        for parameters: [PONativeAlternativePaymentMethodParameter], completion: @escaping ([String: String]) -> Void
    )
}

extension PONativeAlternativePaymentMethodDelegate {

    /// Method provides an ability to supply default values for given parameters. It is not mandatory
    /// to provide defaults for all parameters.
    ///
    /// - Returns: Dictionary where key is a parameter key, and value is desired default.
    @_spi(PO)
    @MainActor
    public func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        await withCheckedContinuation { continuation in
            nativeAlternativePaymentMethodDefaultValues(for: parameters) { continuation.resume(returning: $0) }
        }
    }
}
