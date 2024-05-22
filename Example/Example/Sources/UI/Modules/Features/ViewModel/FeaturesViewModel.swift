//
//  FeaturesViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
import PassKit
import ProcessOut
import ProcessOutUI

final class FeaturesViewModel: BaseViewModel<FeaturesViewModelState>, FeaturesViewModelType {

    init(router: any RouterType<FeaturesRoute>) {
        self.router = router
        super.init(state: .idle)
    }

    override func start() {
        guard case .idle = state else {
            return
        }
        var features: [State.Feature] = [
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
                    self?.startCardTokenization(threeDSService: .test)
                }
            ),
            .init(
                name: Strings.Features.CardPayment.Checkout.title,
                accessibilityId: "features.card-payment",
                select: { [weak self] in
                    self?.startCardTokenization(threeDSService: .checkout)
                }
            )
        ]
        if POPassKitPaymentAuthorizationController.canMakePayments() {
            let feature = State.Feature(
                name: Strings.Features.ApplePay.title,
                accessibilityId: "features.apple-pay",
                select: { [weak self] in
                    self?.authorizePassKitPayment()
                }
            )
            features.append(feature)
        }
        state = .started(State.Started(features: features))
    }

    // MARK: - Private Properties

    private let router: any RouterType<FeaturesRoute>

    // MARK: - Private Methods

    private func startCardTokenization(threeDSService: CardPayment3DSService) {
        let route = FeaturesRoute.cardTokenization(threeDSService: threeDSService) { [weak self] result in
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

    private func authorizePassKitPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Constants.merchantId as? String ?? ""
        request.merchantCapabilities = [.threeDSecure]
        request.paymentSummaryItems = [
            .init(label: "Test", amount: 1)
        ]
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        guard let controller = POPassKitPaymentAuthorizationController(paymentRequest: request) else {
            preconditionFailure("Unable to start PassKit payment authorization.")
        }
        controller.delegate = self
        controller.present()
    }
}

extension FeaturesViewModel: POPassKitPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: POPassKitPaymentAuthorizationController) {
        controller.dismiss()
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didTokenizePayment payment: PKPayment,
        card: POCard
    ) async -> PKPaymentAuthorizationResult {
        .init(status: .success, errors: nil)
    }
}
