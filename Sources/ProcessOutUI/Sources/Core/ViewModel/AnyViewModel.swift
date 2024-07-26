//
//  AnyViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.06.2024.
//

import Combine

/// Type erased view model.
///
/// On iOS 15 Swift runtime is unable to demangle the type of property `let base: any ViewModel<State>`. As
/// a workaround (that requires a bit more code) "classic" type erase implementation is used to silence this warning and
/// avoid potential issues.
final class AnyViewModel<State>: ViewModel {

    init(erasing viewModel: some ViewModel<State>) {
        self.base = ViewModelBox(base: viewModel)
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - CardTokenizationViewModel

    var state: State {
        get { base.state }
        set { base.state = newValue }
    }

    func start() {
        base.start()
    }

    func stop() {
        base.stop()
    }

    // MARK: - Private Properties

    private let base: AnyViewModelBase<State>
    private var cancellable: AnyCancellable?
}

private class ViewModelBox<T>: AnyViewModelBase<T.State> where T: ViewModel {

    init(base: T) {
        self.base = base
    }

    let base: T

    override var state: T.State {
        get { base.state }
        set { base.state = newValue }
    }

    override func start() {
        base.start()
    }

    override func stop() {
        base.stop()
    }
}

// swiftlint:disable unavailable_function unused_setter_value

private class AnyViewModelBase<State>: ViewModel {

    var state: State {
        get { fatalError("Not implemented") }
        set { fatalError("Not implemented") }
    }

    func start() {
        fatalError("Not implemented")
    }

    func stop() {
        fatalError("Not implemented")
    }
}

// swiftlint:enable unavailable_function unused_setter_value
