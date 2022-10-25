//
//  InteractorType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.08.2022.
//

protocol InteractorType: AnyObject {

    associatedtype State

    /// Current view model's state.
    var state: State { get }

    /// A closure that is invoked after the object has changed.
    var didChange: (() -> Void)? { get set }

    /// Starts interactor.
    /// It's expected that implementation of this method should have logic responsible for
    /// interactor starting process, e.g. loading initial content.
    func start()
}
