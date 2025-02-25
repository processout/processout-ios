//
//  POSavedPaymentMethodsEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.02.2025.
//

@_spi(PO) import ProcessOut

/// Events emitted by the saved payment methods view throughout its lifecycle.
@_spi(PO)
public enum POSavedPaymentMethodsEvent: Sendable {

    public typealias PaymentMethod = PODynamicCheckoutPaymentMethod.CustomerToken

    public struct DidStart: Sendable {

        /// Available payment methods.
        public let paymentMethods: [PaymentMethod]
    }

    public struct DidDeletePaymentMethod: Sendable {

        /// The deleted payment method.
        public let paymentMethod: PaymentMethod

        /// The result of the removal operation.
        public let result: Result<Void, POFailure>
    }

    /// Sent before any other event.
    case willStart

    /// Indicates that the initial data load was successful.
    case didStart(DidStart)

    /// Triggered when the user is prompted to confirm payment method removal.
    case didRequestDeleteConfirmation(_ paymentMethod: PaymentMethod)

    /// Emitted after the user confirms removal, before the deletion starts.
    case willDeletePaymentMethod(_ paymentMethod: PaymentMethod)

    /// Sent after payment method removal, regardless of success or failure.
    case didDeletePaymentMethod(DidDeletePaymentMethod)

    /// Emitted when the saved payment methods view completes.
    case didComplete(Result<Void, POFailure>)

    /// Reserved for future events to maintain backward compatibility.
    /// - Warning: Do not match this case directly; use `default` instead.
    @_spi(PO)
    case unknown
}
