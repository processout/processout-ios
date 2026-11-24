//
//  PONativeAlternativePaymentCaptureRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2022.
//

import Foundation

public struct PONativeAlternativePaymentCaptureRequest: Sendable, Codable {

    /// Invoice identifier.
    public let invoiceId: String

    /// Gateway configuration id that was used to initiate native alternative payment.
    public let gatewayConfigurationId: String

    /// Maximum timeout to wait for capture.
    public let timeout: TimeInterval?

    public init(invoiceId: String, gatewayConfigurationId: String, timeout: TimeInterval? = nil) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.timeout = timeout
    }
}
