//
//  POCardTokenizationEvent.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 30.08.2023.
//

import ProcessOut

/// Describes events that could happen during card tokenization lifecycle.
public enum POCardTokenizationEvent {

    /// Initial event that is sent prior any other event.
    case willStart

    /// Indicates that implementation successfully loaded initial portion of data and currently waiting for user
    /// to fulfil needed info.
    case didStart

    /// Event is sent when the user changes any editable value.
    case parametersChanged

    /// Event is sent just before tokenizing card, this is usually a result of a user action, e.g. button press.
    case willTokenizeCard

    /// Sent in case parameters were submitted successfully meaning card was tokenized.
    case didTokenize(card: POCard)

    /// Event is sent after tokenized card was processed. This is a final event.
    case didComplete
}
