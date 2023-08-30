//
//  POCardTokenizationEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.08.2023.
//

/// Describes events that could happen during card tokenization lifecycle.
public enum POCardTokenizationEvent {

    /// Initial event that is sent prior any other event.
    case willStart

    /// Indicates that implementation successfully loaded initial portion of data and currently waiting for user
    /// to fulfill needed info.
    case didStart

    /// Event is sent when the user changes any editable value.
    case parametersChanged

    /// Event is sent just before sending user input, this is usually a result of a user action, e.g. button press.
    case willSubmitParameters

    /// Sent in case parameters were submitted successfully. You could inspect the associated value to understand
    /// whether card will be additionally processed.
    case didSubmitParameters

    /// Event is sent after payment was confirmed to be captured. This is a final event.
    case didCompleteTokenization
}
