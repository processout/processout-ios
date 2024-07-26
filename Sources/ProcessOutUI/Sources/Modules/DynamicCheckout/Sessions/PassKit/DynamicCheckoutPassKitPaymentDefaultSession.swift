//
//  DynamicCheckoutPassKitPaymentDefaultSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import PassKit
import ProcessOut

final class DynamicCheckoutPassKitPaymentDefaultSession: DynamicCheckoutPassKitPaymentSession {

    init(delegate: PODynamicCheckoutDelegate?, invoicesService: POInvoicesService) {
        self.delegate = delegate
        self.invoicesService = invoicesService
        didAuthorizeInvoice = false
    }

    nonisolated var isSupported: Bool {
        POPassKitPaymentAuthorizationController.canMakePayments()
    }

    func start(invoiceId: String, request: PKPaymentRequest) async throws {
        await delegate?.dynamicCheckout(willAuthorizeInvoiceWith: request)
        guard let controller = POPassKitPaymentAuthorizationController(paymentRequest: request) else {
            assertionFailure("ApplePay payment shouldn't be attempted when unavailable.")
            throw POFailure(code: .generic(.mobile))
        }
        self.invoiceId = invoiceId
        controller.delegate = self
        _ = await controller.present()
        await withCheckedContinuation { continuation in
            self.didFinishContinuation = continuation
        }
        await controller.dismiss()
        if didAuthorizeInvoice {
            return
        }
        throw POFailure(code: .cancelled)
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    private var didFinishContinuation: CheckedContinuation<Void, Never>?
    private var didAuthorizeInvoice: Bool
    private var invoiceId: String?

    private weak var delegate: PODynamicCheckoutDelegate?
}

extension DynamicCheckoutPassKitPaymentDefaultSession: POPassKitPaymentAuthorizationControllerDelegate {

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
        guard let invoiceId else {
            preconditionFailure("Invoice ID must be set.")
        }
        var authorizationRequest = POInvoiceAuthorizationRequest(invoiceId: invoiceId, source: card.id)
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
