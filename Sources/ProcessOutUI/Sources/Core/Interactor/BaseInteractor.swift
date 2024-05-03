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

    var state: State {
        didSet { didChange?() }
    }

    var didChange: (() -> Void)?

    @MainActor
    func start() {
        // Does nothing
    }
}
