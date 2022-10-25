//
//  BaseInteractor.swift
//  Example
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

class BaseInteractor<State>: InteractorType {

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

    func start() {
        // Does nothing
    }
}
