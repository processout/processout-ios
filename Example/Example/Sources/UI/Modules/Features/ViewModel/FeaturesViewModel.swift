//
//  FeaturesViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation

final class FeaturesViewModel: BaseViewModel<FeaturesViewModelState>, FeaturesViewModelType {

    init(router: any RouterType<FeaturesRoute>) {
        self.router = router
        super.init(state: .idle)
    }

    override func start() {
        guard case .idle = state else {
            return
        }
        let startedState = State.Started(features: [
            .init(
                name: Strings.Features.NativeAlternativePayment.title,
                accessibilityId: "features.native-alternative-payment",
                select: { [weak self] in
                    self?.router.trigger(route: .gatewayConfigurations(filter: .nativeAlternativePaymentMethods))
                }
            ),
            .init(
                name: Strings.Features.AlternativePayment.title,
                accessibilityId: "features.alternative-payment",
                select: { [weak self] in
                    self?.router.trigger(route: .gatewayConfigurations(filter: .alternativePaymentMethods))
                }
            )
        ])
        state = .started(startedState)
    }

    // MARK: - Private Properties

    private let router: any RouterType<FeaturesRoute>
}
