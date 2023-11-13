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
            ),
            .init(
                name: Strings.Features.CardPayment.title,
                accessibilityId: "features.card-payment",
                select: { [weak self] in
                    self?.startCardTokenization()
                }
            )
        ])
        state = .started(startedState)
    }

    // MARK: - Private Properties

    private let router: any RouterType<FeaturesRoute>

    // MARK: - Private Methods

    private func startCardTokenization() {
        let route = FeaturesRoute.cardTokenization { [weak self] result in
            let message: String
            switch result {
            case .success(let card):
                message = Strings.Features.CardPayment.success(card.id)
            case .failure(let failure):
                if let errorMessage = failure.message {
                    message = Strings.Features.CardPayment.error(errorMessage)
                } else {
                    message = Strings.Features.CardPayment.errorGeneric
                }
            }
            self?.router.trigger(route: .alert(message: message))
        }
        router.trigger(route: route)
    }
}
