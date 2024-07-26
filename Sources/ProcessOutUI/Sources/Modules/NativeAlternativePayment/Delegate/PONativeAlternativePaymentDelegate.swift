//
//  PONativeAlternativePaymentMethodDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2023.
//

import ProcessOut

/// Native alternative payment module delegate definition.
public protocol PONativeAlternativePaymentDelegate: AnyObject, Sendable {

    /// Invoked when module emits event.
    @MainActor
    func nativeAlternativePaymentDidEmitEvent(_ event: PONativeAlternativePaymentEvent)

    /// Method provides an ability to supply default values for given parameters. Completion expects dictionary
    /// where key is a parameter key, and value is desired default. It is not mandatory to provide defaults for
    /// all parameters.
    /// - NOTE: completion must be called on `main` thread.
    @MainActor
    func nativeAlternativePaymentDefaultValues(
        for parameters: [PONativeAlternativePaymentMethodParameter],
        completion: @escaping @Sendable ([String: String]) -> Void
    )
}
