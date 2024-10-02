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
    var delegate: PONativeAlternativePaymentDelegate? { get set }

    /// Updates value for given key.
    func updateValue(_ value: String?, for key: String)

    /// Submits parameters.
    func submit()

    /// Confirms that capture preconditions are satisfied and implementation could proceed with capture.
    ///
    /// - NOTE: Implementation does nothing if manual confirmation is not needed.
    func confirmCapture()

    /// Notifies interactor that user requested cancel confirmation.
    func didRequestCancelConfirmation()
}
