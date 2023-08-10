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

        /// The most recent error message.
        var recentErrorMessage: String?
    }

    struct Tokenized {

        /// Tokenized card.
        let card: POCard

        /// Full card number.
        let cardNumber: String
    }

    struct ProcessingCard {

        /// Tokenized state state snapshot.
        let snapshot: Tokenized

        /// Merchant supplied invoice authorization request.
        let request: POInvoiceAuthorizationRequest
    }

    // swiftlint:disable:next line_length
    case idle, started(Started), tokenizing(snapshot: Started), tokenized(Tokenized), failure(POFailure), processingCard(ProcessingCard)
}
