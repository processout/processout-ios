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

    /// - Parameters:
    ///   - invoiceId: Invoice that that user wants to authorize via native APM.
    ///   - gatewayConfigurationId: Gateway configuration id.
    public static func with(invoiceId: String, gatewayConfigurationId: String) -> Self {
        Self(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId)
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
        let api: ProcessOutApiType = ProcessOut.shared
        let interactor = DefaultNativeAlternativePaymentMethodInteractor(
            invoicesService: api.invoices,
            imagesRepository: api.images,
            configuration: .init(
                gatewayConfigurationId: gatewayConfigurationId,
                invoiceId: invoiceId,
                waitsPaymentConfirmation: configuration.waitsPaymentConfirmation,
                paymentConfirmationTimeout: configuration.paymentConfirmationTimeout
            ),
            logger: api.logger,
            delegate: delegate
        )
        let viewModel = DefaultNativeAlternativePaymentMethodViewModel(
            interactor: interactor, configuration: configuration, completion: completion
        )
        let viewController = NativeAlternativePaymentMethodViewController(
            viewModel: viewModel, customStyle: style, logger: api.logger
        )
        return viewController
    }

    // MARK: -

    init(invoiceId: String, gatewayConfigurationId: String) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        configuration = .init()
    }

    // MARK: - Private Properties

    private let gatewayConfigurationId: String
    private let invoiceId: String

    private var configuration: PONativeAlternativePaymentMethodConfiguration
    private var style: PONativeAlternativePaymentMethodStyle?
    private var completion: ((Result<Void, POFailure>) -> Void)?
    private weak var delegate: PONativeAlternativePaymentMethodDelegate?
}
