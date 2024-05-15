//
//  FeaturesViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
import PassKit
@_spi(PO) import ProcessOut
import ProcessOutUI

final class FeaturesViewModel: BaseViewModel<FeaturesViewModelState>, FeaturesViewModelType {

    init(invoicesService: POInvoicesService, router: any RouterType<FeaturesRoute>) {
        self.invoicesService = invoicesService
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
                    self?.startCardTokenization(threeDSService: .test)
                }
            ),
            .init(
                name: Strings.Features.CardPayment.Checkout.title,
                accessibilityId: "features.card-payment",
                select: { [weak self] in
                    self?.startCardTokenization(threeDSService: .checkout)
                }
            ),
            .init(
                name: Strings.Features.DynamicCheckout.title,
                accessibilityId: "features.dynamic-checkout",
                select: { [weak self] in
                    self?.startDynamicCheckout()
                }
            )
        ])
        state = .started(startedState)
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
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

    private func startDynamicCheckout() {
        Task { @MainActor in
            let invoiceCreationRequest = POInvoiceCreationRequest(
                name: "Example", amount: "100", currency: "EUR", customerId: Constants.customerId
            )
            guard let invoice = try? await self.invoicesService.createInvoice(request: invoiceCreationRequest) else {
                return
            }
            var configuraiton = PODynamicCheckoutConfiguration(invoiceId: invoice.id)
            configuraiton.alternativePayment.returnUrl = Constants.returnUrl
            self.router.trigger(route: .dynamicCheckout(configuration: configuraiton, delegate: self))
        }
    }
}

extension FeaturesViewModel: PODynamicCheckoutDelegate {

    func dynamicCheckout(
        willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest
    ) async -> any PO3DSService {
        POTest3DSService(returnUrl: Constants.returnUrl)
    }

    func dynamicCheckout(willAuthorizeInvoiceWith request: PKPaymentRequest) async {
        request.paymentSummaryItems = [
            .init(label: "Something", amount: 100, type: .final)
        ]
    }
}
