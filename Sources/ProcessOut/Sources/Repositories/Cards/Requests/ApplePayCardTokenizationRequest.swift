//
//  ApplePayCardTokenizationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

import Foundation

struct ApplePayCardTokenizationRequest: Encodable {

    struct PaymentMethod {

        /// Card display name.
        let displayName: String?

        /// Card network.
        let network: String?

        /// Card type.
        let type: String?
    }

    struct PaymentData: Codable {

        /// Encrypted payment data.
        let data: String

        /// Additional version-dependent information you use to decrypt and verify the payment.
        let header: [String: String]

        /// Signature of the payment and header data.
        let signature: String

        /// Version information about the payment token.
        let version: String
    }

    struct ApplePayToken {

        /// Payment data.
        let paymentData: PaymentData

        /// Payment method.
        let paymentMethod: PaymentMethod

        /// Transaction identifier.
        let transactionIdentifier: String
    }

    struct ApplePay: Encodable {

        /// Token details.
        let token: ApplePayToken
    }

    /// Token type.
    let tokenType: String

    /// Contact information.
    let contact: POContact?

    /// Additional metadata.
    let metadata: [String: String]?

    /// Payment information.
    let applepayResponse: ApplePay
}

extension ApplePayCardTokenizationRequest.PaymentMethod: Encodable {

    func encode(to encoder: Encoder) throws {
        let content = [
            "displayName": displayName, "network": network, "type": type
        ]
        var container = encoder.singleValueContainer()
        try container.encode(content)
    }
}

extension ApplePayCardTokenizationRequest.ApplePayToken: Encodable {

    func encode(to encoder: Encoder) throws {
        let content: [String: AnyEncodable] = [
            "paymentData": .init(paymentData),
            "paymentMethod": .init(paymentMethod),
            "transactionIdentifier": .init(transactionIdentifier)
        ]
        var container = encoder.singleValueContainer()
        try container.encode(content)
    }
}
