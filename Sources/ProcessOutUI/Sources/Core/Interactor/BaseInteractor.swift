//
//  BaseInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.10.2023.
//

class BaseInteractor<State>: Interactor {

    init(state: State) {
        self.state = state
    }

    /// Interactor's state.
    var state: State {
        didSet { didChange?() }
    }

    /// A closure that is invoked after the object has changed.
    var didChange: (() -> Void)? {
        didSet { didChange?() }
    }

    @MainActor
    func start() {
        // Does nothing
    }
}
