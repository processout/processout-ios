//
//  PODynamicCheckoutAlternativePaymentDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import ProcessOut

protocol PODynamicCheckoutAlternativePaymentDelegate: AnyObject {

    /// Invoked when module emits APM event.
    func dynamicCheckout(didEmitAlternativePaymentEvent event: PONativeAlternativePaymentEvent)

    /// Method provides an ability to supply default values for given parameters. Completion expects dictionary
    /// where key is a parameter key, and value is desired default. It is not mandatory to provide defaults for
    /// all parameters.
    /// - NOTE: completion must be called on `main` thread.
    func dynamicCheckout(
        defaultValuesFor alternativePaymentParameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String]
}
