//
//  AnyDynamicCheckoutViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 15.05.2024.
//

import Combine

final class AnyDynamicCheckoutViewModel: DynamicCheckoutViewModel {

    init(erasing viewModel: some DynamicCheckoutViewModel) {
        self.base = viewModel
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    let base: any DynamicCheckoutViewModel

    // MARK: - CardTokenizationViewModel

    func start() {
        base.start()
    }

    var state: DynamicCheckoutViewModelState {
        base.state
    }

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?
}
