//
//  ViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

@MainActor
protocol ViewModelType<State>: AnyObject {

    associatedtype State

    /// Current view model's state.
    var state: State { get }

    /// A closure that is invoked after the object has changed.
    var didChange: (() -> Void)? { get set }

    /// Starts view model.
    /// It's expected that implementation of this method should have logic responsible for
    /// view model starting process, e.g. loading initial content.
    func start()
}
