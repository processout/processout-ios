//
//  CardTokenizationInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

protocol CardTokenizationInteractor: Interactor<CardTokenizationInteractorState> {

    /// Tokenization configuration.
    var configuration: POCardTokenizationConfiguration { get }

    /// Updates card information parameter with given id.
    func update(parameterId: State.ParameterId, value: String)

    /// Changes preferred scheme to use when tokenizing card.
    func setPreferredScheme(_ scheme: String)

    /// Starts card tokenization.
    func tokenize()

    /// Cancells tokenization if possible.
    func cancel()
}
