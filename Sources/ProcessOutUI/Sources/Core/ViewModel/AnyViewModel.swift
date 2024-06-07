//
//  AnyViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.06.2024.
//

import Combine

final class AnyViewModel<State>: ViewModel {

    init(erasing viewModel: some ViewModel<State>) {
        self.base = viewModel
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    let base: any ViewModel<State>

    // MARK: - CardTokenizationViewModel

    func start() {
        base.start()
    }

    var state: State {
        get { base.state }
        set { base.state = newValue }
    }

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?
}
