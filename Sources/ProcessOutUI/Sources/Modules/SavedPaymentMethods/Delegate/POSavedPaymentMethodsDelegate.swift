//
//  POSavedPaymentMethodsDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.02.2025.
//

/// Saved payment methods view delegate.
public protocol POSavedPaymentMethodsDelegate: AnyObject, Sendable {

    /// Invoked when view emits an event.
    @_spi(PO)
    @MainActor
    func savedPaymentMethods(didEmitEvent event: POSavedPaymentMethodsEvent)
}

extension POSavedPaymentMethodsDelegate {

    @MainActor
    @_spi(PO)
    public func savedPaymentMethods(didEmitEvent event: POSavedPaymentMethodsEvent) {
        // NOP
    }
}
