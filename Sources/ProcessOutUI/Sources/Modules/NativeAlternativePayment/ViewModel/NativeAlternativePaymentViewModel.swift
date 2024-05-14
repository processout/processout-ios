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

    /// Boolean value that indicates whether payment is already captured.
    var isCaptured: Bool { get }

    /// Starts view model.
    func start()
}
