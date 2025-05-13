//
//  SavedPaymentMethodsInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

@MainActor
protocol SavedPaymentMethodsInteractor: Interactor<SavedPaymentMethodsInteractorState> {

    /// Configuration.
    var configuration: POSavedPaymentMethodsConfiguration { get }

    /// Deletes customer token ID.
    func delete(customerTokenId: String)

    /// Notifies interactor that user requested removal confirmation.
    func didRequestRemovalConfirmation(customerTokenId: String)
}
