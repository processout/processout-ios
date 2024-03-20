//
//  PODynamicCheckoutDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import ProcessOut

public protocol PODynamicCheckoutDelegate: AnyObject {

    /// Invoked when module emits dynamic checkout event.
    /// - NOTE: default implementation does nothing.
    func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent)

    /// Called when dynamic checkout is about to authorize invoice with given request.
    ///
    /// Your implementation may alter request parameters and return new request but make
    /// sure that invoice id and source stay the same.
    ///
    /// - NOTE: default implementation returns unmodified request as is.
    func dynamicCheckout(willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest) async
}

extension PODynamicCheckoutDelegate {

    public func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent) {
        // Ignored
    }

    public func dynamicCheckout(willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest) async {
        // Ignored
    }
}
