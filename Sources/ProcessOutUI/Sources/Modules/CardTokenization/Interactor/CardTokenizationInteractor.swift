//
//  CardTokenizationInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation

protocol CardTokenizationInteractor: ObservableObject {

    typealias State = CardTokenizationInteractorState

    /// Current state.
    var state: State { get }

    /// Starts interactor.
    func start()

    /// Updates card information parameter with given id.
    func update(parameterId: State.ParameterId, value: String)

    /// Changes preferred scheme to use when tokenizing card.
    func setPreferredScheme(_ scheme: String)

    /// Starts card tokenization.
    func tokenize()

    /// Cancells tokenization if possible.
    func cancel()
}
