//
//  DynamicCheckoutInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

protocol DynamicCheckoutInteractor: Interactor<DynamicCheckoutInteractorState> {

    /// Starts payment using payment method with ID.
    @discardableResult
    func initiatePayment(methodId: String) -> Bool

    /// Submits current payment method's data.
    func submit()

    /// Cancells payment.
    func cancel()
}
