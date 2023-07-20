//
//  CardTokenizationInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

protocol CardTokenizationInteractor: Interactor<CardTokenizationInteractorState> {

    /// Updates card information at given key path.
    func update(parameterAt path: WritableKeyPath<State.Started, State.Parameter?>, value: String)

    /// Starts card tokenization.
    func tokenize()

    /// Cancells tokenization if possible.
    func cancel()
}
