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

    /// Attempts to cancel dynamic checkout payment.
    /// - Returns: `true` if payment cancellation was started.
    /// - NOTE: Cancellation is not necessarily immediate and may happen after some time.
    @discardableResult
    func cancel() -> Bool
}
