//
//  SavedPaymentMethodsInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

@MainActor
protocol SavedPaymentMethodsInteractor: Interactor<SavedPaymentMethodsInteractorState> {

    /// Deletes customer token ID.
    func delete(customerTokenId: String)
}
