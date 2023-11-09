//
//  POCardUpdateEvent.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

/// Describes events that could happen during card update lifecycle.
public enum POCardUpdateEvent {

    /// Initial event that is sent prior any other event.
    case willStart

    /// Indicates that implementation successfully loaded initial portion of data and currently waiting for user
    /// to fulfill needed info.
    case didStart

    /// Event is sent when the user changes any editable value.
    case parametersChanged

    /// Event is sent just before tokenizing card, this is usually a result of a user action, e.g. button press.
    case willUpdateCard

    /// Event is sent after card is updated. This is a final event.
    case didComplete
}
