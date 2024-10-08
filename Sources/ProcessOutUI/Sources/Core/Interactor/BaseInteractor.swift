//
//  BaseInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.10.2023.
//

class BaseInteractor<State: InteractorState>: Interactor {

    init(state: State) {
        self.state = state
    }

    var state: State {
        willSet {
            willChange?(newValue)
        }
        didSet {
            didChange?()
        }
    }

    var didChange: (() -> Void)?
    var willChange: ((State) -> Void)?

    func start() {
        // Does nothing
    }

    func cancel() {
        // Does nothing
    }
}
