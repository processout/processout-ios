//
//  PODynamicCheckoutDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit
@_spi(PO) import ProcessOut

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
    @MainActor
    func dynamicCheckout(
        willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest,
        using paymentMethod: PODynamicCheckoutPaymentMethod
    ) async -> PO3DS2Service

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func dynamicCheckout(shouldContinueAfter failure: POFailure) -> Bool

    /// Your implementation could return a request that will be used to fetch new invoice to replace existing one
    /// to be able to recover from normally unrecoverable payment failure.
    ///
    /// - NOTE: Please make sure to invalidate old invoice if you decide to create new.
    @MainActor
    func dynamicCheckout(
        newInvoiceFor invoice: POInvoice, invalidationReason: PODynamicCheckoutInvoiceInvalidationReason
    ) async -> POInvoiceRequest?

    /// Allows your implementation to customize saved payment methods configuration.
    @MainActor
    func dynamicCheckout(
        savedPaymentMethodsConfigurationWith invoiceRequest: POInvoiceRequest
    ) -> POSavedPaymentMethodsConfiguration

    // MARK: - Card Payment

    /// Invoked when module emits event.
    @MainActor
    func dynamicCheckout(didEmitCardTokenizationEvent event: POCardTokenizationEvent)

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    @MainActor
    func dynamicCheckout(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String?

    /// Notifies the delegate before a card scanning session begins and allows
    /// providing a delegate to handle scanning events.
    @MainActor
    func dynamicCheckout(willScanCardWith configuration: POCardScannerConfiguration) -> POCardScannerDelegate?

    // MARK: - Alternative Payment

    /// Invoked when module emits alternative payment event.
    @MainActor
    func dynamicCheckout(didEmitAlternativePaymentEvent event: PONativeAlternativePaymentEvent)

    /// Method provides an ability to supply default values for given parameters.
    ///
    /// - Returns: dictionary where key is a parameter key, and value is desired default. Please note that it is not
    /// mandatory to provide defaults for all parameters.
    @MainActor
    func dynamicCheckout(
        alternativePaymentDefaultsWith request: PODynamicCheckoutAlternativePaymentDefaultsRequest
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

    @MainActor
    public func dynamicCheckout(
        newInvoiceFor invoice: POInvoice, invalidationReason: PODynamicCheckoutInvoiceInvalidationReason
    ) async -> POInvoiceRequest? {
        nil
    }

    @MainActor
    public func dynamicCheckout(
        savedPaymentMethodsConfigurationWith invoiceRequest: POInvoiceRequest
    ) -> POSavedPaymentMethodsConfiguration {
        .init(invoiceRequest: invoiceRequest)
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
    public func dynamicCheckout(willScanCardWith configuration: POCardScannerConfiguration) -> POCardScannerDelegate? {
        nil
    }

    @MainActor
    public func dynamicCheckout(didEmitAlternativePaymentEvent event: PONativeAlternativePaymentEvent) {
        // Ignored
    }

    @MainActor
    public func dynamicCheckout(
        alternativePaymentDefaultsWith request: PODynamicCheckoutAlternativePaymentDefaultsRequest
    ) async -> [String: String] {
        [:]
    }

    @MainActor
    public func dynamicCheckout(willAuthorizeInvoiceWith request: PKPaymentRequest) async {
        // Ignored
    }
}
