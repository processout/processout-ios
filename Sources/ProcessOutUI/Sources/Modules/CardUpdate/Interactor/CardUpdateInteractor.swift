//
//  CardUpdateInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

protocol CardUpdateInteractor: Interactor<CardUpdateInteractorState> {

    /// Updates CVC value.
    func update(cvc: String)

    /// Changes preferred scheme.
    func setPreferredScheme(_ scheme: String)

    /// Attempts to update card with new CVC.
    func submit()

    /// Cancells update if possible.
    func cancel()
}
