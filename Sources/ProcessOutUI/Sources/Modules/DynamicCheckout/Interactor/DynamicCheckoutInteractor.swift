//
//  DynamicCheckoutInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

@MainActor
protocol DynamicCheckoutInteractor: Interactor<DynamicCheckoutInteractorState> {

    /// Configuration.
    var configuration: PODynamicCheckoutConfiguration { get }

    /// Changes payment method saving selection.
    func setShouldSaveSelectedPaymentMethod(_ shouldSave: Bool)

    /// Selects payment method with Given ID.
    func select(methodId: String)

    /// Starts payment using payment method with ID.
    /// Please note that only selected payment method can be started.
    func startPayment(methodId: String)

    /// Notifies interactor that user requested cancel confirmation.
    func didRequestCancelConfirmation()
}
