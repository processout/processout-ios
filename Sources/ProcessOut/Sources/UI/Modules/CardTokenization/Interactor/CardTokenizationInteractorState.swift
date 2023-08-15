//
//  CardTokenizationInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation

enum CardTokenizationInteractorState {

    typealias ParameterId = WritableKeyPath<Started, Parameter>

    struct Parameter {

        /// Parameter identifier
        let id: ParameterId

        /// Actual parameter value.
        var value: String = ""

        /// Indicates whether parameter is valid.
        var isValid = true

        /// Formatter that can be used to format this parameter.
        var formatter: Formatter?
    }

    struct Started {

        /// Number of the card.
        var number: Parameter

        /// Expiry date of the card.
        var expiration: Parameter

        /// Card Verification Code of the card.
        var cvc: Parameter

        /// Name of cardholder.
        var cardholderName: Parameter

        /// Card issuer information based on number.
        var issuerInformation: POCardIssuerInformation?

        /// Boolean value identifying whether co-scheme is preferred over scheme.
        var prefersCoScheme: Bool

        /// The most recent error message.
        var recentErrorMessage: String?
    }

    struct Tokenized {

        /// Tokenized card.
        let card: POCard

        /// Full card number.
        let cardNumber: String
    }

    case idle

    /// Interactor has started and is ready.
    case started(Started)

    /// Card information is currently being tokenized.
    case tokenizing(snapshot: Started)

    /// Card was successfully tokenized. This is a sink state.
    case tokenized(Tokenized)

    /// Card tokenization did end with unrecoverable failure. This is a sink state.
    case failure(POFailure)
}
