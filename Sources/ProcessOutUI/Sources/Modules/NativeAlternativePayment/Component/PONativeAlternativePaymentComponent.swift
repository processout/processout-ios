//
//  PONativeAlternativePaymentComponent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.10.2025.
//

@_spi(PO) import ProcessOut

/// A component responsible for managing the native alternative payment, allowing external control.
@MainActor
public final class PONativeAlternativePaymentComponent {

    public init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegateV2? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        var logger = ProcessOut.shared.logger
        switch configuration.flow {
        case .authorization(let flow):
            logger[attributeKey: .invoiceId] = flow.invoiceId
            logger[attributeKey: .gatewayConfigurationId] = flow.gatewayConfigurationId
            logger[attributeKey: .customerTokenId] = flow.customerTokenId
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
            alternativePaymentsService: ProcessOut.shared.alternativePayments,
            imagesRepository: ProcessOut.shared.images,
            barcodeImageProvider: DefaultBarcodeImageProvider(logger: logger),
            logger: logger,
            completion: completion
        )
        interactor.delegate = delegate
        self.interactor = interactor
    }

    /// Starts the payment.
    public func start() async {
        await interactor.start()
    }

    /// Cancels the ongoing payment.
    public func cancel() {
        interactor.cancel()
    }

    // MARK: - Internal

    let interactor: any NativeAlternativePaymentInteractor
}
