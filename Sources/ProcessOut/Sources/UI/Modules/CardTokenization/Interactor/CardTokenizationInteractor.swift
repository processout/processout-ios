//
//  CardTokenizationInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

protocol CardTokenizationInteractor: Interactor<CardTokenizationInteractorState> {

    /// Updates card information parameter with given id.
    func update(parameterId: State.ParameterId, value: String)

    /// Starts card tokenization.
    func tokenize()

    /// Cancells tokenization if possible.
    func cancel()
}
