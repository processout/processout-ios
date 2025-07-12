//
//  NativeAlternativePaymentInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

@MainActor
protocol NativeAlternativePaymentInteractor: Interactor<NativeAlternativePaymentInteractorState> {

    /// Configuration.
    var configuration: PONativeAlternativePaymentConfiguration { get }

    /// Delegate.
    var delegate: PONativeAlternativePaymentDelegateV2? { get set }

    /// Updates value for given key.
    func updateValue(_ value: PONativeAlternativePaymentParameterValue, for key: String)

    /// Submits parameters.
    func submit()

    /// Confirms that payment preconditions are satisfied and implementation could proceed.
    ///
    /// - NOTE: Implementation does nothing if manual confirmation is not needed.
    func confirmPayment()

    /// Confirms redirect to external web page.
    func confirmRedirect()

    /// Notifies interactor that user requested cancel confirmation.
    func didRequestCancelConfirmation()
}
