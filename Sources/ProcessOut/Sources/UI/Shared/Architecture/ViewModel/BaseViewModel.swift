//
//  BaseViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

@available(*, deprecated)
class BaseViewModel<State>: ViewModel {

    init(state: State) {
        self.state = state
    }

    /// View model's state.
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
