//
//  PONativeAlternativePaymentMethodModuleBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import UIKit

public final class PONativeAlternativePaymentMethodViewControllerBuilder { // swiftlint:disable:this type_name

    /// - Parameters:
    ///   - invoiceId: Invoice that that user wants to authorize via native APM.
    ///   - gatewayConfigurationId: Gateway configuration id.
    public static func with(invoiceId: String, gatewayConfigurationId: String) -> Self {
        Self(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId)
    }

    /// Api that will be used by created module to communicate with BE. By default ``ProcessOutApi/shared``
    /// instance is used.
    public func with(api: ProcessOutApiType) -> Self {
        self.api = api
        return self
    }

    /// Completion to invoke after authorization is completed successfully.
    public func with(completion: @escaping () -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = self.api ?? ProcessOutApi.shared
        let interactor = NativeAlternativePaymentMethodInteractor(
            gatewayConfigurationsRepository: api.gatewayConfigurations,
            invoicesService: api.invoices,
            gatewayConfigurationId: gatewayConfigurationId,
            invoiceId: invoiceId
        )
        let router = NativeAlternativePaymentMethodRouter()
        let viewModel = NativeAlternativePaymentMethodViewModel(
            interactor: interactor, router: router, completion: completion
        )
        let viewController = NativeAlternativePaymentMethodViewController(viewModel: viewModel)
        router.viewController = viewController
        return viewController
    }

    // MARK: -

    init(invoiceId: String, gatewayConfigurationId: String) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
    }

    // MARK: - Private Properties

    private let gatewayConfigurationId: String
    private let invoiceId: String

    private var api: ProcessOutApiType?
    private var completion: (() -> Void)?
}
