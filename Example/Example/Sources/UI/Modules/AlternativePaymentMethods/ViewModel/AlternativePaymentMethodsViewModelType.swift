//
//  AlternativePaymentMethodsViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation

protocol AlternativePaymentMethodsViewModelType: ViewModelType<AlternativePaymentMethodsViewModelState> {

    /// Restarts view model.
    func restart()

    /// Loads more configurations.
    func loadMore()
}

enum AlternativePaymentMethodsViewModelState {

    struct ConfigurationItem {

        /// Configuration name.
        let name: String

        /// Triggers payment flow using given configuration.
        let pay: () -> Void
    }

    struct FailureItem: Hashable {

        /// Failure description.
        let description: String
    }

    enum Item: Hashable {
        case configuration(ConfigurationItem), failure(FailureItem)
    }

    struct Started {

        /// Available items..
        let items: [Item]

        /// Boolean value indicating if some operations are being executed at a moment.
        let areOperationsExecuting: Bool
    }

    case idle, started(Started)
}

extension AlternativePaymentMethodsViewModelState.ConfigurationItem: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
