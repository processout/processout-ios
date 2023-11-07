//
//  CardUpdateViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import Combine
@_spi(PO) import ProcessOutCoreUI

protocol CardUpdateViewModel: ObservableObject {

    /// Screen title.
    var title: String? { get }

    /// Available items.
    var items: [CardUpdateViewModelItem] { get }

    /// Available actions.
    var actions: [POActionsContainerActionViewModel] { get }

    /// Currently focused item identifier.
    var focusedItemId: AnyHashable? { get set }
}
