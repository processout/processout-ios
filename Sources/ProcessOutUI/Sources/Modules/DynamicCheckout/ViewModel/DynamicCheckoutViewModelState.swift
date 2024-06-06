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
    let actions: [POActionsContainerActionViewModel]

    /// Indicates whether state represents final success state.
    let isCompleted: Bool

    /// Confirmation dialog to present to user.
    var confirmationDialog: POConfirmationDialog?
}

// todo(andrii-vysotskyi): add protocol to avoid duplicating comment every time
extension DynamicCheckoutViewModelState {

    static let idle = DynamicCheckoutViewModelState(sections: [], actions: [], isCompleted: false)

    /// Section's animation identity. For now only properties that may affect layout
    /// changes are part of identity.
    ///
    /// - NOTE: When this property changes view should be updated with
    /// explicit animation.
    var animationIdentity: AnyHashable {
        [sections.map(\.animationIdentity), actions.map(\.id)]
    }
}

extension DynamicCheckoutViewModelState.Section {

    var animationIdentity: AnyHashable {
        [id, items.map(\.animationIdentity), AnyHashable(isTight), AnyHashable(areBezelsVisible)]
    }
}
