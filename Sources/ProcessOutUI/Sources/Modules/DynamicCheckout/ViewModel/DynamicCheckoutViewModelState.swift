//
//  DynamicCheckoutViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.05.2024.
//

@_spi(PO) import ProcessOutCoreUI

struct DynamicCheckoutViewModelState {

    /// Available sections.
    let sections: [DynamicCheckoutViewModelSection]

    /// Available actions.
    let actions: [POActionsContainerActionViewModel]

    /// Indicates whether state represents final success state.
    let isCompleted: Bool
}

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
