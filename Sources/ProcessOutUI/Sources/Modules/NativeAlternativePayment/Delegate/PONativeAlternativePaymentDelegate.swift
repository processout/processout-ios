//
//  PONativeAlternativePaymentDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import ProcessOut

/// Native alternative payment module delegate definition.
///
/// See original [protocol](https://swiftpackageindex.com/processout/processout-ios/documentation/processout/ponativealternativepaymentmethoddelegate) for details.
public protocol PONativeAlternativePaymentDelegate: AnyObject {

    /// Invoked when module emits event.
    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEvent)

    /// Method provides an ability to supply default values for given parameters. Completion expects dictionary
    /// where key is a parameter key, and value is desired default. It is not mandatory to provide defaults for
    /// all parameters.
    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String]
}

extension PONativeAlternativePaymentDelegate {

    public func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEvent) {
        // Ignored
    }

    public func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        [:]
    }
}
