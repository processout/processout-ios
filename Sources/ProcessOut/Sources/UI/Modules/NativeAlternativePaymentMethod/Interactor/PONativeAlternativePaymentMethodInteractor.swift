//
//  PONativeAlternativePaymentMethodInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation

// todo(andrii-vysotskyi): migrate interactor and dependencies to UI module when ready
@_spi(PO) public protocol PONativeAlternativePaymentMethodInteractor: AnyObject {

    typealias State = PONativeAlternativePaymentMethodInteractorState

    /// Interactor's state.
    var state: State { get }

    /// A closure that is invoked after the object has changed.
    var didChange: (() -> Void)? { get set }

    /// Starts interactor.
    /// It's expected that implementation of this method should have logic responsible for
    /// interactor starting process, e.g. loading initial content.
    func start()

    /// Updates value for given key.
    func updateValue(_ value: String?, for key: String)

    /// Returns formatter that could be used to format given value type if any.
    func formatter(type: PONativeAlternativePaymentMethodParameter.ParameterType) -> Formatter?

    /// Submits parameters.
    func submit()

    /// Cancells payment if possible.
    func cancel()

    /// Notifies interactor that user requested cancel confirmation.
    func didRequestCancelConfirmation()
}
