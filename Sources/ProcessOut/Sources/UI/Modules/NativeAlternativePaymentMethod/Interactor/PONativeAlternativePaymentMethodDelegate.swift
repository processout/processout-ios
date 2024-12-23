//
//  PONativeAlternativePaymentMethodDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2023.
//

/// Native alternative payment module delegate definition.
@preconcurrency
public protocol PONativeAlternativePaymentMethodDelegate: AnyObject, Sendable {

    /// Invoked when module emits event.
    @MainActor
    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentMethodEvent)

    /// Method provides an ability to supply default values for given parameters. It is not mandatory
    /// to provide defaults for all parameters.
    ///
    /// - Returns: Dictionary where key is a parameter key, and value is desired default.
    @MainActor
    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String]

    // MARK: - Deprecated symbols

    /// Invoked when module emits event.
    @available(*, deprecated, renamed: "nativeAlternativePayment(didEmitEvent:)")
    @MainActor
    func nativeAlternativePaymentMethodDidEmitEvent(_ event: PONativeAlternativePaymentMethodEvent)

    /// Method provides an ability to supply default values for given parameters. Completion expects dictionary
    /// where key is a parameter key, and value is desired default. It is not mandatory to provide defaults for
    /// all parameters.
    /// - NOTE: completion must be called on `main` thread.
    @available(*, deprecated, renamed: "nativeAlternativePayment(defaultValuesFor:)")
    @MainActor
    func nativeAlternativePaymentMethodDefaultValues(
        for parameters: [PONativeAlternativePaymentMethodParameter], completion: @escaping ([String: String]) -> Void
    )
}

extension PONativeAlternativePaymentMethodDelegate {

    @MainActor
    public func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentMethodEvent) {
        nativeAlternativePaymentMethodDidEmitEvent(event)
    }

    @MainActor
    public func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        await withCheckedContinuation { continuation in
            nativeAlternativePaymentMethodDefaultValues(for: parameters) { continuation.resume(returning: $0) }
        }
    }

    @available(*, deprecated, renamed: "nativeAlternativePayment(didEmitEvent:)")
    @MainActor
    public func nativeAlternativePaymentMethodDidEmitEvent(_ event: PONativeAlternativePaymentMethodEvent) {
        // Ignored
    }

    @available(*, deprecated, renamed: "nativeAlternativePayment(defaultValuesFor:)")
    @MainActor
    public func nativeAlternativePaymentMethodDefaultValues(
        for parameters: [PONativeAlternativePaymentMethodParameter],
        completion: @escaping ([String: String]) -> Void
    ) {
        completion([:])
    }
}
