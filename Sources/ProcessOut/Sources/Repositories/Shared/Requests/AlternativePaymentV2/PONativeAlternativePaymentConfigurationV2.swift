//
//  PONativeAlternativePaymentConfigurationV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2026.
//

/// Payment configuration.
public struct PONativeAlternativePaymentConfigurationV2: Sendable, Encodable {

    public struct ReturnRedirectType: Sendable {

        /// Redirect type raw value.
        let rawValue: String
    }

    /// Return redirect type.
    public let returnRedirectType: ReturnRedirectType

    public init(returnRedirectType: ReturnRedirectType = .automatic) {
        self.returnRedirectType = returnRedirectType
    }
}

extension PONativeAlternativePaymentConfigurationV2.ReturnRedirectType {

    /// Redirect result is handled automatically.
    public static let automatic = Self(rawValue: "automatic")

    /// Redirect result is not processed automatically and should be resolved explicitly.
    @_spi(PO)
    public static let manual = Self(rawValue: "manual")
}

extension PONativeAlternativePaymentConfigurationV2.ReturnRedirectType: Encodable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
