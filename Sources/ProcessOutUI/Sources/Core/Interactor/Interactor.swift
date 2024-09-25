//
//  Interactor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.10.2023.
//

protocol Interactor<State>: AnyObject {

    associatedtype State

    /// Interactor's state.
    var state: State { get }

    /// A closure that is invoked right before the object's state is changed.
    var willChange: ((_ newState: State) -> Void)? { get set }

    /// A closure that is invoked after the object's state has changed.
    var didChange: (() -> Void)? { get set }

    /// Starts interactor.
    /// It's expected that implementation of this method should have logic responsible for
    /// interactor starting process, e.g. loading initial content.
    func start()

    /// Requests cancellation.
    func cancel()
}
