//
//  DynamicCheckoutPassKitPaymentDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import PassKit
import ProcessOut

@MainActor
final class DynamicCheckoutPassKitPaymentDefaultInteractor: DynamicCheckoutPassKitPaymentInteractor {

    init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate?,
        invoicesService: POInvoicesService
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.invoicesService = invoicesService
        didAuthorizeInvoice = false
    }

    nonisolated var isSupported: Bool {
        POPassKitPaymentAuthorizationController.canMakePayments()
    }

    func start(request: PKPaymentRequest) async throws {
        guard let controller = POPassKitPaymentAuthorizationController(paymentRequest: request) else {
            assertionFailure("ApplePay payment shouldn't be attempted when unavailable.")
            throw POFailure(code: .generic(.mobile))
        }
        controller.delegate = self
        _ = await controller.present()
        await withCheckedContinuation { continuation in
            self.didFinishContinuation = continuation
        }
        await controller.dismiss()
        if didAuthorizeInvoice {
            return
        }
        throw POFailure(code: .generic(.mobile))
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let configuration: PODynamicCheckoutConfiguration
    private weak var delegate: PODynamicCheckoutDelegate?

    private var didFinishContinuation: CheckedContinuation<Void, Never>?
    private var didAuthorizeInvoice: Bool
}

extension DynamicCheckoutPassKitPaymentDefaultInteractor: POPassKitPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: POPassKitPaymentAuthorizationController) {
        guard let didFinishContinuation else {
            preconditionFailure("Continue must be set.")
        }
        didFinishContinuation.resume()
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didTokenizePayment payment: PKPayment,
        card: POCard
    ) async -> PKPaymentAuthorizationResult {
        var authorizationRequest = POInvoiceAuthorizationRequest(invoiceId: configuration.invoiceId, source: card.id)
        do {
            guard let delegate else {
                throw POFailure(message: "Delegate must be set to authorize invoice.", code: .generic(.mobile))
            }
            let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &authorizationRequest)
            try await invoicesService.authorizeInvoice(request: authorizationRequest, threeDSService: threeDSService)
            didAuthorizeInvoice = true
        } catch {
            return .init(status: .failure, errors: [error])
        }
        return .init(status: .success, errors: nil)
    }
}
