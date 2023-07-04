//
//  PONativeAlternativePaymentMethodModuleBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import UIKit

/// Provides an ability to create view controller that could be used to handle Native
/// Alternative Payment. Call ``PONativeAlternativePaymentMethodViewControllerBuilder/build()``
/// to create view controller's instance.
public final class PONativeAlternativePaymentMethodViewControllerBuilder { // swiftlint:disable:this type_name

    @available(*, deprecated, message: "Use non static method instead.")
    public static func with(
        invoiceId: String, gatewayConfigurationId: String
    ) -> PONativeAlternativePaymentMethodViewControllerBuilder {
        PONativeAlternativePaymentMethodViewControllerBuilder()
            .with(invoiceId: invoiceId)
            .with(gatewayConfigurationId: gatewayConfigurationId)
    }

    /// Creates builder instance.
    public init() {
        configuration = .init()
        style = PONativeAlternativePaymentMethodStyle()
    }

    /// Invoice that that user wants to authorize via native APM.
    public func with(invoiceId: String) -> Self {
        self.invoiceId = invoiceId
        return self
    }

    /// Gateway configuration id.
    public func with(gatewayConfigurationId: String) -> Self {
        self.gatewayConfigurationId = gatewayConfigurationId
        return self
    }

    /// Completion to invoke after flow is completed.
    public func with(completion: @escaping (Result<Void, POFailure>) -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Module's delegate.
    /// - NOTE: Delegate is weakly referenced.
    public func with(delegate: PONativeAlternativePaymentMethodDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    /// Sets UI configuration.
    public func with(configuration: PONativeAlternativePaymentMethodConfiguration) -> Self {
        self.configuration = configuration
        return self
    }

    /// Sets UI style.
    public func with(style: PONativeAlternativePaymentMethodStyle) -> Self {
        self.style = style
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        guard let gatewayConfigurationId, let invoiceId else {
            preconditionFailure("Gateway configuration id and invoice id must be set.")
        }
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
        var logger = api.logger
        logger[attributeKey: "InvoiceId"] = invoiceId
        let interactor = DefaultNativeAlternativePaymentMethodInteractor(
            invoicesService: api.invoices,
            imagesRepository: api.images,
            configuration: .init(
                gatewayConfigurationId: gatewayConfigurationId,
                invoiceId: invoiceId,
                waitsPaymentConfirmation: configuration.waitsPaymentConfirmation,
                paymentConfirmationTimeout: configuration.paymentConfirmationTimeout
            ),
            logger: logger,
            delegate: delegate
        )
        let viewModel = DefaultNativeAlternativePaymentMethodViewModel(
            interactor: interactor, configuration: configuration, completion: completion
        )
        return NativeAlternativePaymentMethodViewController(viewModel: viewModel, style: style, logger: logger)
    }

    // MARK: - Private Properties

    private var gatewayConfigurationId: String?
    private var invoiceId: String?
    private var configuration: PONativeAlternativePaymentMethodConfiguration
    private var style: PONativeAlternativePaymentMethodStyle
    private var completion: ((Result<Void, POFailure>) -> Void)?
    private weak var delegate: PONativeAlternativePaymentMethodDelegate?
}
