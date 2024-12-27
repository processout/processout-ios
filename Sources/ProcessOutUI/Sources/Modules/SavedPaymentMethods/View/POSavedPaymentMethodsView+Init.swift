//
//  POSavedPaymentMethodsView+Init.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

@_spi(PO) import ProcessOut

@available(iOS 14, *)
extension POSavedPaymentMethodsView {

    /// Creates saved payment methods view.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behaviour.
    public init(
        configuration: POSavedPaymentMethodsConfiguration,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let viewModel = {
            var logger = ProcessOut.shared.logger
            logger[attributeKey: .invoiceId] = configuration.invoiceId
            let interactor = DefaultSavedPaymentMethodsInteractor(
                configuration: configuration,
                invoicesService: ProcessOut.shared.invoices,
                customerTokensService: ProcessOut.shared.customerTokens,
                logger: logger,
                completion: completion
            )
            return DefaultSavedPaymentMethodsViewModel(interactor: interactor)
        }
        self = .init(viewModel: viewModel())
    }
}
