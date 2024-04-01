//
//  PONativeAlternativePaymentCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.03.2024.
//

public protocol PONativeAlternativePaymentCoordinator: AnyObject {

    /// Payment configuration.
    var configuration: PONativeAlternativePaymentConfiguration { get }

    /// Payment state.
    var paymentState: PONativeAlternativePaymentState { get }

    /// Attempts to submit current form.
    func submit()

    /// Cancells payment if possible.
    @discardableResult
    func cancel() -> Bool
}
