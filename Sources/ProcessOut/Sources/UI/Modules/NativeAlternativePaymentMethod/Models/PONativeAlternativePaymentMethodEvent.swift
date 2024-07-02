//
//  PONativeAlternativePaymentMethodEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.02.2023.
//

/// Describes events that could happen during native alternative payment module lifecycle.
public enum PONativeAlternativePaymentMethodEvent {

    public struct WillSubmitParameters {

        /// Available parameters.
        public let parameters: [PONativeAlternativePaymentMethodParameter]

        /// Parameter values.
        public let values: [String: String]

        @_spi(PO)
        public init(parameters: [PONativeAlternativePaymentMethodParameter], values: [String: String]) {
            self.parameters = parameters
            self.values = values
        }
    }

    public struct ParametersChanged {

        /// Parameter definition.
        public let parameter: PONativeAlternativePaymentMethodParameter

        /// Parameter value.
        public let value: String

        @_spi(PO)
        public init(parameter: PONativeAlternativePaymentMethodParameter, value: String) {
            self.parameter = parameter
            self.value = value
        }
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
    case didSubmitParameters(additionalParametersExpected: Bool)

    /// Sent in case parameters submission failed and if error is retriable, otherwise expect `didFail` event.
    case didFailToSubmitParameters(failure: POFailure)

    /// Event is sent after all information is collected, and implementation is waiting for a PSP to confirm capture.
    /// You could check associated value `additionalActionExpected` to understand whether user needs
    /// to execute additional action(s) outside application, for example confirming operation in his/her banking app
    /// to make capture happen.
    case willWaitForCaptureConfirmation(additionalActionExpected: Bool)

    /// Event is sent after payment was confirmed to be captured. This is a final event.
    case didCompletePayment

    /// Event is sent in case unretryable error occurs. This is a final event.
    case didFail(failure: POFailure)
}
