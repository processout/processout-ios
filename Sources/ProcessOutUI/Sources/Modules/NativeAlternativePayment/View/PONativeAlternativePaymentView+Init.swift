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
    ///
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    public init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegate? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let viewModel = {
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
            return DefaultNativeAlternativePaymentViewModel(interactor: interactor)
        }
        self = .init(viewModel: viewModel())
    }
}
