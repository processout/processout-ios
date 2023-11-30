//
//  PONativeAlternativePaymentView+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

@_spi(PO) import ProcessOut

@available(iOS 14, *)
extension PONativeAlternativePaymentView {

    /// Creates native APM view.
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        configuration: PONativeAlternativePaymentConfiguration = .init(),
        delegate: PONativeAlternativePaymentMethodDelegate? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        var logger = ProcessOut.shared.logger
        logger[attributeKey: "InvoiceId"] = invoiceId
        let interactorConfiguration = PONativeAlternativePaymentMethodInteractorConfiguration(
            gatewayConfigurationId: gatewayConfigurationId,
            invoiceId: invoiceId,
            waitsPaymentConfirmation: configuration.waitsPaymentConfirmation,
            paymentConfirmationTimeout: configuration.paymentConfirmationTimeout
        )
        let interactor = PODefaultNativeAlternativePaymentMethodInteractor(
            invoicesService: ProcessOut.shared.invoices,
            imagesRepository: ProcessOut.shared.images,
            configuration: interactorConfiguration,
            logger: logger,
            delegate: delegate
        )
        let viewModel = DefaultNativeAlternativePaymentViewModel(
            interactor: interactor, configuration: configuration, completion: completion
        )
        self = .init(viewModel: viewModel)
    }
}
