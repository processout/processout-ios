//
//  CardPaymentViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import Foundation

protocol CardPaymentViewModelType: ViewModelType<CardPaymentViewModelState> {

    /// Initiates card payment.
    func pay()
}

enum CardPaymentViewModelState {

    struct SectionIdentifier: Hashable {

        /// Section title.
        let title: String
    }

    struct Section {

        /// Section identifier.
        let identifier: SectionIdentifier

        /// Section items.
        let parameters: [Parameter]
    }

    enum ParameterType: Hashable {
        case number, text
    }

    struct Parameter: Hashable {

        /// Parameter value.
        @ReferenceTypeBox
        var value: String

        /// Parameter placeholder.
        let placeholder: String

        /// Parameter type.
        let parameterType: ParameterType

        /// Accessibility identifier.
        let accessibilityId: String
    }

    struct Started {

        /// Available items.
        let sections: [Section]
    }

    case idle, started(Started)
}
