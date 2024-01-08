//
//  PONativeAlternativePaymentMethodInteractorConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.03.2023.
//

import Foundation

@_spi(PO) public struct PONativeAlternativePaymentMethodInteractorConfiguration { // swiftlint:disable:this type_name

    /// Gateway configuration id.
    public let gatewayConfigurationId: String

    /// Invoice identifier.
    public let invoiceId: String

    /// Indicates whether interactor should wait for payment confirmation or not.
    public let waitsPaymentConfirmation: Bool

    /// Maximum amount of time to wait for payment confirmation if it is enabled.
    public let paymentConfirmationTimeout: TimeInterval

    public init(
        gatewayConfigurationId: String,
        invoiceId: String,
        waitsPaymentConfirmation: Bool,
        paymentConfirmationTimeout: TimeInterval
    ) {
        self.gatewayConfigurationId = gatewayConfigurationId
        self.invoiceId = invoiceId
        self.waitsPaymentConfirmation = waitsPaymentConfirmation
        self.paymentConfirmationTimeout = paymentConfirmationTimeout
    }
}
