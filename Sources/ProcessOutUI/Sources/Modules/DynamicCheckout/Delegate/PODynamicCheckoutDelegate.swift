//
//  PODynamicCheckoutDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit
import ProcessOut

/// Dynamic checkout module delegate.
public protocol PODynamicCheckoutDelegate: AnyObject {

    /// Invoked when module emits dynamic checkout event.
    /// - NOTE: default implementation does nothing.
    func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent)

    /// Called when dynamic checkout is about to authorize invoice with given request.
    ///
    /// Your implementation may alter request parameters and return new request but make
    /// sure that invoice id and source stay the same.
    func dynamicCheckout(willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest) async -> PO3DSService

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    func dynamicCheckout(shouldContinueAfter failure: POFailure) -> Bool

    // MARK: - Card Payment

    /// Invoked when module emits event.
    func dynamicCheckout(didEmitCardTokenizationEvent event: POCardTokenizationEvent)

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    func dynamicCheckout(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String?

    // MARK: - Alternative Payment

    /// Invoked when module emits alternative payment event.
    func dynamicCheckout(didEmitAlternativePaymentEvent event: PONativeAlternativePaymentEvent)

    /// Method provides an ability to supply default values for given parameters.
    ///
    /// - Returns: dictionary where key is a parameter key, and value is desired default. Please note that it is not
    /// mandatory to provide defaults for all parameters.
    func dynamicCheckout(
        alternativePaymentDefaultsFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String]

    // MARK: - Pass Kit

    /// Gives implementation an opportunity to modify payment request before it is used to authorize invoice.
    func dynamicCheckout(willAuthorizeInvoiceWith request: PKPaymentRequest) async
}

extension PODynamicCheckoutDelegate {

    public func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent) {
        // Ignored
    }

    public func dynamicCheckout(shouldContinueAfter failure: POFailure) -> Bool {
        true
    }

    public func dynamicCheckout(didEmitCardTokenizationEvent event: POCardTokenizationEvent) {
        // Ignored
    }

    public func dynamicCheckout(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String? {
        issuerInformation.scheme
    }

    public func dynamicCheckout(didEmitAlternativePaymentEvent event: PONativeAlternativePaymentEvent) {
        // Ignored
    }

    public func dynamicCheckout(
        alternativePaymentDefaultsFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        [:]
    }

    public func dynamicCheckout(willAuthorizeInvoiceWith request: PKPaymentRequest) async {
        // Ignored
    }
}
