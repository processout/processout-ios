//
//  AlternativePaymentMethodsBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit
import ProcessOut

final class AlternativePaymentMethodsBuilder {

    init(filter: POAllGatewayConfigurationsRequest.Filter) {
        self.filter = filter
    }

    func build() -> UIViewController {
        let interactor = AlternativePaymentMethodsInteractor(
            gatewayConfigurationsRepository: ProcessOutApi.shared.gatewayConfigurations,
            invoicesService: ProcessOutApi.shared.invoices,
            filter: filter
        )
        let router = AlternativePaymentMethodsRouter()
        let viewModel = AlternativePaymentMethodsViewModel(
            interactor: interactor, router: router, prefersNative: filter == .nativeAlternativePaymentMethods
        )
        let viewController = AlternativePaymentMethodsViewController(viewModel: viewModel)
        router.viewController = viewController
        return viewController
    }

    // MARK: - Private Properties

    private let filter: POAllGatewayConfigurationsRequest.Filter
}
