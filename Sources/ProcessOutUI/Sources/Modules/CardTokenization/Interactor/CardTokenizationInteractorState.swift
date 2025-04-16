//
//  CardTokenizationInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation
import ProcessOut

enum CardTokenizationInteractorState {

    struct Started {

        /// Number of the card.
        var number: Parameter

        /// Expiry date of the card.
        var expiration: Parameter

        /// Card Verification Code of the card.
        var cvc: Parameter

        /// Name of cardholder.
        var cardholderName: Parameter

        /// Preliminary card scheme not yet confirmed by API.
        var preliminaryScheme: POCardScheme?

        /// Card issuer information based on number.
        var issuerInformation: POCardIssuerInformation?

        /// Preferred scheme.
        var preferredScheme: POCardScheme?

        /// Billing address parameters.
        var address: AddressParameters

        /// Indicates whether card should be saved for future payments.
        var shouldSaveCard: Bool = false

        /// The most recent error message.
        var recentErrorMessage: String?
    }

    struct Tokenizing {

        /// Started state snapshot.
        let snapshot: Started

        /// Tokenization task.
        let task: Task<Void, Never>
    }

    struct AddressParameters {

        /// Billing address country.
        var country: Parameter

        /// Billing address street line 1.
        var street1: Parameter

        /// Billing address street line 2.
        var street2: Parameter

        /// Billing address city.
        var city: Parameter

        /// Billing address state.
        var state: Parameter

        /// Billing address postal code.
        var postalCode: Parameter

        /// Address country specification.
        var specification: AddressSpecification
    }

    struct Parameter {

        /// Parameter identifier
        let id: ParameterId

        /// Actual parameter value.
        var value: String = ""

        /// Indicates whether parameter is valid.
        var isValid = true

        /// Boolean flag indicating whether parameter should be collected.
        var shouldCollect = true // todo(andrii-vysotskyi): consider migrating to optional parameters

        /// Available parameter values.
        var availableValues: [ParameterValue] = []

        /// Formatter that can be used to format this parameter.
        var formatter: Formatter?
    }

    struct ParameterValue: Decodable, Hashable {

        /// Display name of value.
        let displayName: String

        /// Actual parameter value.
        let value: String
    }

    typealias ParameterId = WritableKeyPath<Started, Parameter>

    case idle

    /// Interactor has started and is ready.
    case started(Started)

    /// Card information is currently being tokenized.
    case tokenizing(Tokenizing)

    /// Card was successfully tokenized. This is a sink state.
    case tokenized

    /// Card tokenization did end with unrecoverable failure. This is a sink state.
    case failure(POFailure)
}

extension CardTokenizationInteractorState: InteractorState {

    var isSink: Bool {
        switch self {
        case .tokenized, .failure:
            return true
        default:
            return false
        }
    }
}

extension CardTokenizationInteractorState.AddressParameters {

    /// Boolean value that allows to determine whether all parameters are valid.
    var areParametersValid: Bool {
        [country, street1, street2, city, state, postalCode].allSatisfy(\.isValid)
    }
}

extension CardTokenizationInteractorState.Started {

    /// Boolean value that allows to determine whether all parameters are valid.
    var areParametersValid: Bool {
        let parameters = [number, expiration, cvc, cardholderName]
        return parameters.allSatisfy(\.isValid) && address.areParametersValid
    }
}
