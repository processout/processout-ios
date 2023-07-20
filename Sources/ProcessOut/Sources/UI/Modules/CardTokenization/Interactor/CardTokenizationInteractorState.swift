//
//  CardTokenizationInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

enum CardTokenizationInteractorState {

    struct Parameter {

        /// Actual parameter value.
        var value: String

        /// Indicates whether parameter is valid.
        var isValid: Bool?
    }

    struct Started {

        /// Number of the card.
        var number: Parameter?

        /// Expiry month of the card.
        var expMonth: Parameter?

        /// Expiry year of the card.
        var expYear: Parameter?

        /// Card Verification Code of the card.
        var cvc: Parameter?

        /// Name of cardholder.
        var cardholderName: Parameter?

        /// The most recent error message.
        var recentErrorMessage: String?
    }

    struct Tokenized {

        /// Tokenized card.
        let card: POCard

        /// Full card number.
        let cardNumber: String
    }

    case idle, started(Started), tokenizing(snapshot: Started), tokenized(Tokenized), failure(POFailure)
}
