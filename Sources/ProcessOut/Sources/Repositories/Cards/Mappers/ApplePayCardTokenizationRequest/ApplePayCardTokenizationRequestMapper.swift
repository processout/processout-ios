//
//  ApplePayCardTokenizationRequestMapper.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 26/10/2022.
//

import Foundation
import PassKit

final class ApplePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapperType {

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    // MARK: - ApplePayCardTokenizationRequestMapperType

    func tokenizationRequest(
        from request: POApplePayCardTokenizationRequest
    ) throws -> ApplePayCardTokenizationRequest {
        let token = ApplePayCardTokenizationRequest.ApplePayToken(
            paymentData: try decoder.decode(
                ApplePayCardTokenizationRequest.PaymentData.self, from: request.payment.token.paymentData
            ),
            paymentMethod: paymentMethod(from: request.payment.token.paymentMethod)
        )
        let tokenizationRequest = ApplePayCardTokenizationRequest(
            tokenType: "applepay",
            contact: request.contact,
            metadata: request.metadata,
            applepayResponse: .init(token: token)
        )
        return tokenizationRequest
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder

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
            paymentMethodType = "unknown"
        }
        let method = ApplePayCardTokenizationRequest.PaymentMethod(
            displayName: paymentMethod.displayName, network: paymentMethod.network?.rawValue, type: paymentMethodType
        )
        return method
    }
}
