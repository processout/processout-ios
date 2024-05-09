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
}

extension DynamicCheckoutViewModelState {

    static let idle = DynamicCheckoutViewModelState(
        sections: [], actions: []
    )

    /// Section's animation identity. For now only properties that may affect layout
    /// changes are part of identity.
    ///
    /// - NOTE: When this property changes view should be updated with
    /// explicit animation.
    var animationIdentity: AnyHashable {
        [sections.map(\.animationIdentity), actions.map(\.id)]
    }
}
