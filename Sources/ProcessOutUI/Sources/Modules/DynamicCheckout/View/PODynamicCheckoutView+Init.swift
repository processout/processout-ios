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
            let logger = ProcessOut.shared.logger
            let interactor = DynamicCheckoutDefaultInteractor(
                configuration: configuration,
                delegate: delegate,
                childProvider: DynamicCheckoutInteractorDefaultChildProvider(
                    configuration: configuration,
                    cardsService: ProcessOut.shared.cards,
                    invoicesService: ProcessOut.shared.invoices,
                    imagesRepository: ProcessOut.shared.images,
                    logger: logger
                ),
                invoicesService: ProcessOut.shared.invoices,
                cardsService: ProcessOut.shared.cards,
                alternativePaymentsService: ProcessOut.shared.alternativePayments,
                logger: logger,
                completion: completion
            )
            return DefaultDynamicCheckoutViewModel(interactor: interactor)
        }
        self = .init(viewModel: viewModel())
    }
}
