//
//  PONativeAlternativePaymentMethodV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2025.
//

/// Payment method details.
public struct PONativeAlternativePaymentMethodV2: Decodable, Sendable {

    /// Gateway name.
    public let gatewayName: String

    /// Payment method logo.
    public let logo: POImageRemoteResource

    /// Payment method display name.
    public let displayName: String
}
