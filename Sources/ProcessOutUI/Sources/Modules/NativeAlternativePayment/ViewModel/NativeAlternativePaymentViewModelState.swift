//
//  NativeAlternativePaymentViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.06.2024.
//

@_spi(PO) import ProcessOutCoreUI

struct NativeAlternativePaymentViewModelState {

    /// Available items.
    let items: [NativeAlternativePaymentViewModelItem]

    /// Currently focused item identifier.
    var focusedItemId: AnyHashable?

    /// Confirmation dialog to present to user.
    var confirmationDialog: POConfirmationDialog?

    /// Form controls information.
    var controls: NativeAlternativePaymentViewModelControlGroup?
}

extension NativeAlternativePaymentViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [items.map(\.animationIdentity), controls?.buttons.map(\.id)]
    }
}

extension NativeAlternativePaymentViewModelState {

    /// Idle state.
    static var idle: NativeAlternativePaymentViewModelState {
        .init(items: [], focusedItemId: nil, confirmationDialog: nil, controls: nil)
    }
}
