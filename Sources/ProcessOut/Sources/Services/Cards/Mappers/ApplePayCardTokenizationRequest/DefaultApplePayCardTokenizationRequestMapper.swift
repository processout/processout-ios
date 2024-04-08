//
//  DefaultApplePayCardTokenizationRequestMapper.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 26/10/2022.
//

import Foundation
import PassKit

final class DefaultApplePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper {

    init(decoder: JSONDecoder, logger: POLogger) {
        self.decoder = decoder
        self.logger = logger
    }

    // MARK: - ApplePayCardTokenizationRequestMapper

    /// - Throws: `POFailure` instance in case of error.
    func tokenizationRequest(
        from request: POApplePayCardTokenizationRequest
    ) throws -> ApplePayCardTokenizationRequest {
        do {
            let token = ApplePayCardTokenizationRequest.ApplePayToken(
                paymentData: try decoder.decode(
                    ApplePayCardTokenizationRequest.PaymentData.self, from: request.payment.token.paymentData
                ),
                paymentMethod: paymentMethod(from: request.payment.token.paymentMethod),
                transactionIdentifier: request.payment.token.transactionIdentifier
            )
            let tokenizationRequest = ApplePayCardTokenizationRequest(
                tokenType: "applepay",
                contact: request.contact,
                shipping: request.shippingContact,
                metadata: request.metadata,
                applepayMid: request.merchantIdentifier,
                applepayResponse: .init(token: token)
            )
            return tokenizationRequest
        } catch {
            logger.error("Did fail to decode payment data: '\(error)'.")
            throw POFailure(message: nil, code: .internal(.mobile), underlyingError: error)
        }
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
    private let logger: POLogger

    // MARK: - Private Methods

    private func paymentMethod(from paymentMethod: PKPaymentMethod) -> ApplePayCardTokenizationRequest.PaymentMethod {
        let paymentMethodType: String
        switch paymentMethod.type {
        case .debit:
            paymentMethodType = "debit"
        case .credit:
            paymentMethodType = "credit"
        case .prepaid:
            paymentMethodType = "prepaid"
        case .store:
            paymentMethodType = "store"
        default:
            logger.info("Unknown payment method type: '\(paymentMethod.type.rawValue)'.")
            paymentMethodType = "unknown"
        }
        let method = ApplePayCardTokenizationRequest.PaymentMethod(
            displayName: paymentMethod.displayName, network: paymentMethod.network?.rawValue, type: paymentMethodType
        )
        return method
    }
}
