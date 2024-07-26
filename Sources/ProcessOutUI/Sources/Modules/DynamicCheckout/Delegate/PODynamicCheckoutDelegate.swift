//
//  PODynamicCheckoutDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit
import ProcessOut

/// Dynamic checkout module delegate.
@_spi(PO)
public protocol PODynamicCheckoutDelegate: AnyObject, Sendable {

    /// Invoked when module emits dynamic checkout event.
    /// - NOTE: default implementation does nothing.
    @MainActor
    func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent)

    /// Called when dynamic checkout is about to authorize invoice with given request.
    ///
    /// Your implementation may alter request parameters and return new request but make
    /// sure that invoice id and source stay the same.
    func dynamicCheckout(
        willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest
    ) async -> PO3DSService

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func dynamicCheckout(shouldContinueAfter failure: POFailure) -> Bool

    /// Your implementation could return new invoice to replace existing one to be able to recover from
    /// normally unrecoverable payment failure.
    func dynamicCheckout(newInvoiceFor invoice: POInvoice) async -> POInvoice?

    // MARK: - Card Payment

    /// Invoked when module emits event.
    @MainActor
    func dynamicCheckout(didEmitCardTokenizationEvent event: POCardTokenizationEvent)

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    @MainActor
    func dynamicCheckout(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String?

    // MARK: - Alternative Payment

    /// Invoked when module emits alternative payment event.
    @MainActor
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
    @MainActor
    func dynamicCheckout(willAuthorizeInvoiceWith request: PKPaymentRequest) async
}

extension PODynamicCheckoutDelegate {

    @MainActor
    public func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent) {
        // Ignored
    }

    @MainActor
    public func dynamicCheckout(shouldContinueAfter failure: POFailure) -> Bool {
        true
    }

    public func dynamicCheckout(newInvoiceFor invoice: POInvoice) async -> POInvoice? {
        nil
    }

    @MainActor
    public func dynamicCheckout(didEmitCardTokenizationEvent event: POCardTokenizationEvent) {
        // Ignored
    }

    @MainActor
    public func dynamicCheckout(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String? {
        issuerInformation.scheme
    }

    @MainActor
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
