//
//  NativeAlternativePaymentViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Combine
@_spi(PO) import ProcessOutCoreUI

protocol NativeAlternativePaymentViewModel: ObservableObject {

    /// Available items.
    var sections: [NativeAlternativePaymentViewModelSection] { get }

    /// Available actions.
    var actions: [POActionsContainerActionViewModel] { get }

    /// Currently focused item identifier.
    var focusedItemId: AnyHashable? { get set }
}
