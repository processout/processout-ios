//
//  PODynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

@_spi(PO) import ProcessOut

@available(iOS 14, *)
extension PODynamicCheckoutView {

    /// Creates dynamic checkout view.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behaviour.
    public init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let viewModel = {
            var logger = ProcessOut.shared.logger
            logger[attributeKey: "InvoiceId"] = configuration.invoiceId
            let interactor = DynamicCheckoutDefaultInteractor(
                configuration: configuration,
                delegate: delegate,
                passKitPaymentSession: DynamicCheckoutPassKitPaymentDefaultSession(
                    configuration: configuration, delegate: delegate, invoicesService: ProcessOut.shared.invoices
                ),
                alternativePaymentSession: DynamicCheckoutAlternativePaymentDefaultSession(
                    configuration: configuration.alternativePayment
                ),
                childProvider: DynamicCheckoutInteractorDefaultChildProvider(
                    configuration: configuration,
                    cardsService: ProcessOut.shared.cards,
                    invoicesService: ProcessOut.shared.invoices,
                    imagesRepository: ProcessOut.shared.images,
                    logger: logger
                ),
                invoicesService: ProcessOut.shared.invoices,
                logger: logger,
                completion: completion
            )
            return DefaultDynamicCheckoutViewModel(interactor: interactor)
        }
        self = .init(viewModel: viewModel())
    }
}
