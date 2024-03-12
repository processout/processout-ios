//
//  PONativeAlternativePaymentCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.03.2024.
//

public protocol PONativeAlternativePaymentCoordinator: AnyObject {

    /// Payment configuration.
    var configuration: PONativeAlternativePaymentConfiguration { get }

    /// Attempts to submit current form.
    func submit()

    /// Cancells payment if possible.
    func cancel()
}
