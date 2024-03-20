//
//  PODynamicCheckoutCardPaymentDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import ProcessOut

public protocol PODynamicCheckoutCardPaymentDelegate: AnyObject {

    /// Invoked when module emits event.
    func dynamicCheckout(didEmitCardTokenizationEvent event: POCardTokenizationEvent)

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    func dynamicCheckout(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String?
}
