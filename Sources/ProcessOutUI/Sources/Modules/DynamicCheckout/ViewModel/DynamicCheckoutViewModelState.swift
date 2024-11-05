//
//  DynamicCheckoutViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.05.2024.
//

@_spi(PO) import ProcessOutCoreUI

struct DynamicCheckoutViewModelState {

    struct Section: Identifiable {

        /// Section ID.
        let id: String

        /// Items.
        let items: [Item]

        /// Defines whether view should be tightly displayed.
        let isTight: Bool

        /// Defines whether view should render bezels (frame) around section content.
        let areBezelsVisible: Bool
    }

    typealias Item = DynamicCheckoutViewModelItem

    /// Available sections.
    let sections: [Section]

    /// Available actions.
    let actions: [POButtonViewModel]

    /// Indicates whether state represents final success state.
    let isCompleted: Bool

    /// Confirmation dialog to present to user.
    var confirmationDialog: POConfirmationDialog?
}

extension DynamicCheckoutViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [sections.map(\.animationIdentity), actions.map(\.id)]
    }

    static var idle: DynamicCheckoutViewModelState {
        .init(sections: [], actions: [], isCompleted: false)
    }
}

extension DynamicCheckoutViewModelState.Section: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [id, items.map(\.animationIdentity), AnyHashable(isTight), AnyHashable(areBezelsVisible)]
    }
}
