//
//  CardUpdateViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import Combine
@_spi(PO) import ProcessOutCoreUI

@MainActor
protocol CardUpdateViewModel: ObservableObject {

    /// Screen title.
    var title: String? { get }

    /// Available sections.
    var sections: [CardUpdateViewModelSection] { get }

    /// Available actions.
    var actions: [POButtonViewModel] { get }

    /// Currently focused item identifier.
    var focusedItemId: AnyHashable? { get set }

    /// Starts view model.
    func start()
}
