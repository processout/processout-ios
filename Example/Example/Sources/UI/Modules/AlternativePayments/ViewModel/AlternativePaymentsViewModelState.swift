//
//  AlternativePaymentMethodsViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation

struct AlternativePaymentsViewModelState {

    struct Section: Identifiable {

        /// Section ID.
        let id: String

        /// Section title.
        let title: String?

        /// Section items.
        let items: [Item]
    }

    enum Item {

        /// Items
        case configuration(ConfigurationItem), error(ErrorItem)
    }

    struct ConfigurationItem: Identifiable {

        /// Item identifier.
        let id: String

        /// Configuration name.
        let name: String

        /// Invoked when this configuration item is selected.
        let select: () -> Void
    }

    struct ErrorItem {

        /// Error message.
        let errorMessage: String
    }

    /// Available sections.
    var sections: [Section]
}

extension AlternativePaymentsViewModelState.Item: Identifiable {

    var id: String {
        switch self {
        case .configuration(let item):
            item.id
        case .error(let item):
            item.errorMessage
        }
    }
}

extension AlternativePaymentsViewModelState {

    /// Idle state.
    static let idle = AlternativePaymentsViewModelState(sections: [])
}
