//
//  PONativeAlternativePaymentMethodTransactionDetailsRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.12.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodTransactionDetailsRequest: Sendable, Codable { // swiftlint:disable:this type_name line_length

    /// Invoice identifier.
    public let invoiceId: String

    /// Gateway configuration identifier.
    public let gatewayConfigurationId: String

    public init(invoiceId: String, gatewayConfigurationId: String) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
    }
}
