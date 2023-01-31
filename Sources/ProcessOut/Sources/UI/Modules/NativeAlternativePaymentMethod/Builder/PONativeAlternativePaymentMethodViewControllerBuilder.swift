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

    /// Api that will be used by created module to communicate with BE. By default ``ProcessOutApi/shared``
    /// instance is used.
    @_spi(PO)
    public func with(api: ProcessOutApiType) -> Self {
        self.api = api
        return self
    }

    /// Completion to invoke after flow is completed.
    public func with(completion: @escaping (Result<Void, POFailure>) -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Sets UI configuration.
    public func with(configuration: PONativeAlternativePaymentMethodUiConfiguration) -> Self {
        self.configuration = configuration
        return self
    }

    /// Sets UI style.
    public func with(style: PONativeAlternativePaymentMethodStyle) -> Self {
        self.style = style
        return self
    }

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    public func with(waitsPaymentConfirmation: Bool) -> Self {
        self.waitsPaymentConfirmation = waitsPaymentConfirmation
        return self
    }

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Maximum value is 180 seconds.
    public func with(paymentConfirmationTimeout: TimeInterval) -> Self {
        self.paymentConfirmationTimeout = paymentConfirmationTimeout
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = self.api ?? ProcessOutApi.shared
        let interactorConfiguration = NativeAlternativePaymentMethodInteractor.Configuration(
            gatewayConfigurationId: gatewayConfigurationId,
            invoiceId: invoiceId,
            waitsPaymentConfirmation: waitsPaymentConfirmation,
            paymentConfirmationTimeout: paymentConfirmationTimeout
        )
        let interactor = NativeAlternativePaymentMethodInteractor(
            invoicesService: api.invoices,
            imagesRepository: api.images,
            configuration: interactorConfiguration,
            logger: api.logger
        )
        let viewModel = NativeAlternativePaymentMethodViewModel(
            interactor: interactor, uiConfiguration: configuration, completion: completion
        )
        let viewController = NativeAlternativePaymentMethodViewController(
            viewModel: viewModel, customStyle: style
        )
        return viewController
    }

    // MARK: -

    init(invoiceId: String, gatewayConfigurationId: String) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        waitsPaymentConfirmation = true
        paymentConfirmationTimeout = 180
    }

    // MARK: - Private Properties

    private let gatewayConfigurationId: String
    private let invoiceId: String

    private var api: ProcessOutApiType?
    private var completion: ((Result<Void, POFailure>) -> Void)?
    private var waitsPaymentConfirmation: Bool
    private var paymentConfirmationTimeout: TimeInterval
    private var configuration: PONativeAlternativePaymentMethodUiConfiguration?
    private var style: PONativeAlternativePaymentMethodStyle?
}
