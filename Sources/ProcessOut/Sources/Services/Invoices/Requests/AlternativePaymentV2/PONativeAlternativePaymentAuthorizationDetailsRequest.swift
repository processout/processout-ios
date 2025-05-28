//
//  PONativeAlternativePaymentAuthorizationDetailsRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.05.2025.
//

import Foundation

/// Represents a request to initiate a native alternative payment.
@_spi(PO)
public struct PONativeAlternativePaymentAuthorizationDetailsRequest: Sendable { // swiftlint:disable:this type_name

    /// Configuration for automatic waiting until payment capture status changes or times out.
    public struct CaptureConfirmation: Sendable {

        /// Maximum duration (in seconds) to wait for the payment state to change
        /// from `PENDING_CAPTURE` to a different state.
        ///
        /// Defaults to 3 minutes (180 seconds).
        public let timeout: TimeInterval

        public init(timeout: TimeInterval = 3 * 60) {
            self.timeout = timeout
        }
    }

    /// Unique identifier for the invoice associated with this payment request.
    public let invoiceId: String

    /// Identifier of the payment gateway configuration to use for this payment.
    public let gatewayConfigurationId: String

    /// Optional configuration that enables automatic waiting for payment capture confirmation.
    public let captureConfirmation: CaptureConfirmation?

    public init(invoiceId: String, gatewayConfigurationId: String, captureConfirmation: CaptureConfirmation? = nil) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.captureConfirmation = captureConfirmation
    }
}
