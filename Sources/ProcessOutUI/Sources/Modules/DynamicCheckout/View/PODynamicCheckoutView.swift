//
//  PODynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut

@available(iOS 14, *)
public struct PODynamicCheckoutView: View {

    public init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.completion = completion
    }

    // MARK: - View

    public var body: some View {
        // todo(andrii-vysotskyi): ensure that view model is created only once, see https://stackoverflow.com/questions/62635914/initialize-stateobject-with-a-parameter-in-swiftui
        var logger = ProcessOut.shared.logger
        logger[attributeKey: "InvoiceId"] = configuration.invoiceId
        let interactor = DynamicCheckoutDefaultInteractor(
            configuration: configuration,
            delegate: delegate,
            passKitPaymentInteractor: DynamicCheckoutPassKitPaymentDefaultInteractor(
                configuration: configuration, delegate: delegate, invoicesService: ProcessOut.shared.invoices
            ),
            alternativePaymentInteractor: DynamicCheckoutAlternativePaymentDefaultInteractor(
                configuration: configuration.alternativePayment
            ),
            childProvider: DefaultDynamicCheckoutInteractorChildProvider(
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
        let viewModel = {
            DefaultDynamicCheckoutViewModel(interactor: interactor)
        }
        return DynamicCheckoutView(viewModel: viewModel())
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutConfiguration
    private let completion: (Result<Void, POFailure>) -> Void

    private weak var delegate: PODynamicCheckoutDelegate?
}
