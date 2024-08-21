//
//  FeaturesViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
import PassKit
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutUI

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
        let features: [State.Feature] = [
            .init(
                name: String(localized: .Features.nativeAlternativePayment),
                accessibilityId: "features.native-alternative-payment",
                select: { [weak self] in
                    self?.router.trigger(route: .gatewayConfigurations(filter: .nativeAlternativePaymentMethods))
                }
            ),
            .init(
                name: String(localized: .Features.alternativePayment),
                accessibilityId: "features.alternative-payment",
                select: { [weak self] in
                    self?.router.trigger(route: .gatewayConfigurations(filter: .alternativePaymentMethods))
                }
            ),
            .init(
                name: String(localized: .Features.cardPayment),
                accessibilityId: "features.card-payment",
                select: { [weak self] in
                    self?.startCardTokenization(threeDSService: .test)
                }
            ),
            .init(
                name: String(localized: .Features.checkoutCardPayment),
                accessibilityId: "features.card-payment",
                select: { [weak self] in
                    self?.startCardTokenization(threeDSService: .checkout)
                }
            ),
            .init(
                name: String(localized: .Features.dynamicCheckout),
                accessibilityId: "features.dynamic-checkout",
                select: { [weak self] in
                    self?.startDynamicCheckout()
                }
            ),
            createPassKitPaymentFeature()
        ].compactMap { $0 }
        state = .started(State.Started(features: features))
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let router: any RouterType<FeaturesRoute>

    // MARK: - Payments

    private func startCardTokenization(threeDSService: CardPayment3DSService) {
        let route = FeaturesRoute.cardTokenization(threeDSService: threeDSService) { [weak self] result in
            let message: String
            switch result {
            case .success:
                message = String(localized: .Features.successMessage)
            case .failure(let failure):
                if let errorMessage = failure.message {
                    var options = String.LocalizationOptions()
                    options.replacements = [errorMessage]
                    message = String(localized: .Features.error, options: options)
                } else {
                    message = String(localized: .Features.genericError)
                }
            }
            self?.router.trigger(route: .alert(message: message))
        }
        router.trigger(route: route)
    }

    private func startDynamicCheckout() {
        Task { @MainActor in
            let invoiceCreationRequest = POInvoiceCreationRequest(
                name: "Example",
                amount: "100",
                currency: "EUR",
                returnUrl: Constants.returnUrl,
                customerId: Constants.customerId
            )
            guard let invoice = try? await self.invoicesService.createInvoice(request: invoiceCreationRequest) else {
                return
            }
            let configuration = PODynamicCheckoutConfiguration(
                invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret),
                alternativePayment: .init(returnUrl: Constants.returnUrl),
                cancelButton: .init(confirmation: .init())
            )
            self.router.trigger(route: .dynamicCheckout(configuration: configuration, delegate: self))
        }
    }

    private func startPassKitPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Constants.merchantId ?? ""
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

    // MARK: - Utils

    private func createPassKitPaymentFeature() -> State.Feature? {
        guard POPassKitPaymentAuthorizationController.canMakePayments() else {
            return nil
        }
        let feature = State.Feature(
            name: String(localized: .Features.applePay),
            accessibilityId: "features.apple-pay",
            select: { [weak self] in
                self?.startPassKitPayment()
            }
        )
        return feature
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
            .init(label: "Test", amount: 100, type: .final)
        ]
    }

    func dynamicCheckout(
        newInvoiceFor invoice: POInvoice, invalidationReason: PODynamicCheckoutInvoiceInvalidationReason
    ) async -> POInvoiceRequest? {
        let request = POInvoiceCreationRequest(
            name: "Example",
            amount: invoice.amount.description,
            currency: invoice.currency,
            returnUrl: invoice.returnUrl,
            customerId: Constants.customerId
        )
        guard let invoice = try? await invoicesService.createInvoice(request: request) else {
            return nil
        }
        return .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret)
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
