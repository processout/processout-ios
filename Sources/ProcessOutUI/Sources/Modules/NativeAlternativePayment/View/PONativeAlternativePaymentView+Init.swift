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
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegate? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        var logger = ProcessOut.shared.logger
        logger[attributeKey: "InvoiceId"] = configuration.invoiceId
        let interactor = NativeAlternativePaymentDefaultInteractor(
            configuration: configuration,
            delegate: delegate,
            invoicesService: ProcessOut.shared.invoices,
            imagesRepository: ProcessOut.shared.images,
            logger: logger,
            completion: completion
        )
        let viewModel = DefaultNativeAlternativePaymentViewModel(interactor: interactor)
        self = .init(viewModel: viewModel)
    }
}
