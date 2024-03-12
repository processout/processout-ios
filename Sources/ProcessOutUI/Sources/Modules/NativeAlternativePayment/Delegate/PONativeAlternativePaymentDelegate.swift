//
//  PONativeAlternativePaymentDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import ProcessOut

/// Native alternative payment module delegate definition.
///
/// See original [protocol](https://swiftpackageindex.com/processout/processout-ios/documentation/processout/ponativealternativepaymentmethoddelegate) for details.
public protocol PONativeAlternativePaymentDelegate: AnyObject {

    /// Invoked when module emits event.
    func nativeAlternativePayment(
        _ coordinator: PONativeAlternativePaymentCoordinator, didEmitEvent event: PONativeAlternativePaymentEvent
    )

    /// Method provides an ability to supply default values for given parameters. Completion expects dictionary
    /// where key is a parameter key, and value is desired default. It is not mandatory to provide defaults for
    /// all parameters.
    /// - NOTE: completion must be called on `main` thread.
    func nativeAlternativePayment(
        _ coordinator: PONativeAlternativePaymentCoordinator,
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String]
}
