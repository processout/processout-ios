//
//  AnyCardTokenizationViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.10.2023.
//

import Combine

final class AnyCardTokenizationViewModel: CardTokenizationViewModel {

    init<ViewModel: CardTokenizationViewModel>(erasing viewModel: ViewModel) {
        self.base = viewModel
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    let base: any CardTokenizationViewModel

    // MARK: - CardTokenizationViewModel

    var state: CardTokenizationViewModelState {
        get { base.state }
        set { base.state = newValue }
    }

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?
}
