//
//  PONativeAlternativePaymentEventV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.05.2025.
//

@_spi(PO) import ProcessOut

/// Describes events that could happen during native alternative payment module lifecycle.
public enum PONativeAlternativePaymentEventV2: Sendable {

    public struct WillSubmitParameters: Sendable {

        /// Available parameters.
        public let parameters: [PONativeAlternativePaymentFormV2.Parameter]
    }

    public struct DidSubmitParameters: Sendable {

        public let additionalParametersExpected: Bool
    }

    public struct WillWaitForPaymentConfirmation: Sendable { }

    public struct ParametersChanged: Sendable {

        /// Parameter definition that the user changed.
        public let parameter: PONativeAlternativePaymentFormV2.Parameter
    }

    public struct DidFail: Sendable {

        /// Failure.
        public let failure: POFailure

        /// Indicates the payment state at the moment the failure occurred.
        ///
        /// This provides additional context about where in the payment process the failure happened.
        /// For example, in case of a user-initiated cancellation, this state can be used to determine
        /// which step the user was on when they canceled.
        public let paymentState: PONativeAlternativePaymentStateV2?
    }

    /// Initial event that is sent prior any other event.
    case willStart

    /// Indicates that implementation successfully loaded initial portion of data and currently waiting for user
    /// to fulfil needed info.
    case didStart

    /// This event is emitted when a user clicks the "Cancel payment" button, prompting the system to display a
    /// confirmation dialog. This event signifies the initiation of the cancellation confirmation process.
    ///
    /// This event can be used for tracking user interactions related to payment cancellations. It helps in
    /// understanding user behaviour, particularly the frequency and context in which users consider canceling a payment.
    case didRequestCancelConfirmation

    /// Event is sent when the user changes any editable value.
    case parametersChanged(ParametersChanged)

    /// Event is sent just before sending user input, this is usually a result of a user action, e.g. button press.
    case willSubmitParameters(WillSubmitParameters)

    /// Sent in case parameters were submitted successfully. You could inspect the associated value to understand
    /// whether additional input is required.
    case didSubmitParameters(DidSubmitParameters)

    /// Sent in case parameters submission failed and if error is retriable, otherwise expect `didFail` event.
    case didFailToSubmitParameters(failure: POFailure)

    /// Event is sent after all information is collected, and implementation is waiting for a PSP to confirm payment.
    case willWaitForPaymentConfirmation(WillWaitForPaymentConfirmation)

    /// This event is triggered during the `PENDING` state when the user confirms that they have completed
    /// any required external action (if applicable). Once the event is triggered, the implementation
    /// proceeds with the actual completion confirmation process.
    case didConfirmPayment

    /// Event is sent after payment was confirmed to be completed. This is a final event.
    case didCompletePayment

    /// Event is sent in case unretryable error occurs. This is a final event.
    case didFail(DidFail)

    // MARK: -

    @_spi(PO)
    case unknown
}
