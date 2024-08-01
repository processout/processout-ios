//
//  AlternativePaymentDataViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

import Foundation

@MainActor
protocol AlternativePaymentDataViewModelType: ViewModelType<AlternativePaymentDataViewModelState> {

    /// Submits items and continues payment.
    func submit()

    /// Triggers item addition.
    func add()
}

enum AlternativePaymentDataViewModelState {

    struct Item {

        /// Item's title.
        let title: String

        /// Item's subtitle if any.
        let subtitle: String?

        /// Removes item.
        let remove: (() -> Void)?
    }

    struct Started {

        /// Items.
        let items: [Item]
    }

    case idle, started(Started)
}

extension AlternativePaymentDataViewModelState.Item: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
    }
}
