//
//  NativeAlternativePaymentViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.06.2024.
//

@_spi(PO) import ProcessOutCoreUI

struct NativeAlternativePaymentViewModelState {

    /// Available items.
    let sections: [NativeAlternativePaymentViewModelSection]

    /// Available actions.
    let actions: [POButtonViewModel]

    /// Boolean value that indicates whether payment is already captured.
    let isCaptured: Bool

    /// Currently focused item identifier.
    var focusedItemId: AnyHashable?

    /// Confirmation dialog to present to user.
    var confirmationDialog: POConfirmationDialog?
}

extension NativeAlternativePaymentViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [sections.map(\.animationIdentity), actions.map(\.id)]
    }
}

extension NativeAlternativePaymentViewModelState {

    /// Idle state.
    static var idle: NativeAlternativePaymentViewModelState {
        .init(sections: [], actions: [], isCaptured: false, focusedItemId: nil, confirmationDialog: nil)
    }
}
