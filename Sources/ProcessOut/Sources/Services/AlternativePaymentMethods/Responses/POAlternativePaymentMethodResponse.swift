//
//  POAlternativePaymentMethodResponse.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

/// Result of alternative payment.
public struct POAlternativePaymentMethodResponse {

    public enum APMReturnType {
        case authorization, createToken
    }

    /// Gateway token starting with prefix gway_req_ that can be used to perform a sale call.
    public let gatewayToken: String

    /// Customer  ID that may be used for creating APM recurring token.
    public let customerId: String?

    /// Customer token ID that may be used for creating APM recurring token.
    public let tokenId: String?

    /// returnType informs if this was an APM token creation or a payment creation response.
    public let returnType: APMReturnType
}
