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
    @_spi(PO)
    public init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegateV2? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let viewModel = {
            var logger = ProcessOut.shared.logger
            switch configuration.flow {
            case .authorization(let flow):
                logger[attributeKey: .invoiceId] = flow.invoiceId
                logger[attributeKey: .gatewayConfigurationId] = flow.gatewayConfigurationId
            case .tokenization(let flow):
                logger[attributeKey: .customerId] = flow.customerId
                logger[attributeKey: .customerTokenId] = flow.customerTokenId
                logger[attributeKey: .gatewayConfigurationId] = flow.gatewayConfigurationId
            }
            let interactor = NativeAlternativePaymentDefaultInteractor(
                configuration: configuration,
                serviceAdapter: DefaultNativeAlternativePaymentServiceAdapter(
                    invoicesService: ProcessOut.shared.invoices,
                    tokensService: ProcessOut.shared.customerTokens,
                    paymentConfirmationTimeout: configuration.paymentConfirmation.timeout
                ),
                imagesRepository: ProcessOut.shared.images,
                barcodeImageProvider: DefaultBarcodeImageProvider(logger: logger),
                logger: logger,
                completion: completion
            )
            interactor.delegate = delegate
            let viewModel = DefaultNativeAlternativePaymentViewModel(interactor: interactor)
            return AnyViewModel(erasing: viewModel)
        }
        self = .init(viewModel: viewModel())
    }

    /// Creates native APM view.
    ///
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    @_disfavoredOverload
    @available(*, deprecated)
    public init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegate? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let viewModel = {
            var logger = ProcessOut.shared.logger
            logger[attributeKey: .invoiceId] = configuration.invoiceId
            logger[attributeKey: .gatewayConfigurationId] = configuration.gatewayConfigurationId
            let interactor = NativeAlternativePaymentDefaultInteractor(
                configuration: configuration,
                serviceAdapter: DefaultNativeAlternativePaymentServiceAdapter(
                    invoicesService: ProcessOut.shared.invoices,
                    tokensService: ProcessOut.shared.customerTokens,
                    paymentConfirmationTimeout: configuration.paymentConfirmation.timeout
                ),
                imagesRepository: ProcessOut.shared.images,
                barcodeImageProvider: DefaultBarcodeImageProvider(logger: logger),
                logger: logger,
                completion: completion
            )
            let viewModel = DefaultNativeAlternativePaymentViewModel(interactor: interactor)
            return AnyViewModel(erasing: viewModel)
        }
        self = .init(viewModel: viewModel())
    }
}
