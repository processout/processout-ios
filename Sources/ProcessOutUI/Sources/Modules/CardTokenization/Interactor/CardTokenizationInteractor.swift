//
//  CardTokenizationInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import ProcessOut

protocol CardTokenizationInteractor: Interactor<CardTokenizationInteractorState> {

    /// Delegate.
    var delegate: POCardTokenizationDelegate? { get set }

    /// Tokenization configuration.
    var configuration: POCardTokenizationConfiguration { get }

    /// Updates card information parameter with given id.
    func update(parameterId: State.ParameterId, value: String)

    /// Changes preferred scheme to use when tokenizing card.
    func setPreferredScheme(_ scheme: POCardScheme)

    /// Changes card saving selection.
    func setShouldSaveCard(_ shouldSave: Bool)

    /// Starts card tokenization.
    func tokenize()
}
