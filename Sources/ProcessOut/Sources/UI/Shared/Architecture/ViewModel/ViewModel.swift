//
//  ViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

@available(*, deprecated)
@MainActor
protocol ViewModel<State>: AnyObject {

    associatedtype State

    /// View model's state.
    var state: State { get }

    /// A closure that is invoked after the object has changed.
    var didChange: (() -> Void)? { get set }

    /// Starts view model.
    /// It's expected that implementation of this method should have logic responsible for
    /// view model starting process, e.g. loading initial content.
    func start()
}
