//
//  NativeAlternativePaymentInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

protocol NativeAlternativePaymentInteractor: Interactor<NativeAlternativePaymentInteractorState> {

    /// Configuration.
    var configuration: PONativeAlternativePaymentConfiguration { get }

    /// Delegate.
    var delegate: PONativeAlternativePaymentDelegate? { get set }

    /// Updates value for given key.
    func updateValue(_ value: String?, for key: String)

    /// Submits parameters.
    func submit()

    /// Cancells payment if possible.
    @discardableResult
    func cancel() -> Bool
}
