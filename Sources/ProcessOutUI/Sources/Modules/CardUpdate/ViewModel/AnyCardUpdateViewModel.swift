//
//  AnyCardUpdateViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import Combine
@_spi(PO) import ProcessOutCoreUI

final class AnyCardUpdateViewModel: CardUpdateViewModel {

    init<ViewModel: CardUpdateViewModel>(erasing viewModel: ViewModel) {
        self.base = viewModel
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    let base: any CardUpdateViewModel

    // MARK: - CardUpdateViewModel

    var title: String? {
        base.title
    }

    var sections: [CardUpdateViewModelSection] {
        base.sections
    }

    var actions: [POButtonViewModel] {
        base.actions
    }

    var focusedItemId: AnyHashable? {
        get { base.focusedItemId }
        set { base.focusedItemId = newValue }
    }

    func start() {
        base.start()
    }

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?
}
