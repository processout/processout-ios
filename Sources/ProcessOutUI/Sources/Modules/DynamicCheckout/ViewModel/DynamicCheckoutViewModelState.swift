//
//  DynamicCheckoutViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.05.2024.
//

import ProcessOut
@_spi(PO) import ProcessOutCoreUI

struct DynamicCheckoutViewModelState {

    struct Section: Identifiable {

        /// Section ID.
        let id: String

        /// Section header.
        let header: SectionHeader?

        /// Items.
        let items: [Item]

        /// Defines whether view should be tightly displayed.
        let isTight: Bool

        /// Defines whether view should render bezels (frame) around section content.
        let areBezelsVisible: Bool
    }

    struct SectionHeader {

        /// Section title.
        let title: String?

        /// Trailing button.
        let button: POButtonViewModel?
    }

    struct SavedPaymentMethods: Identifiable {

        let id: String

        /// Configuration.
        let configuration: POSavedPaymentMethodsConfiguration

        /// Completion.
        let completion: @MainActor (Result<Void, POFailure>) -> Void
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

    /// Saved payment method details.
    var savedPaymentMethods: SavedPaymentMethods?
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
