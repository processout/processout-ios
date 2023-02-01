//
//  PONativeAlternativePaymentMethodConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import Foundation

/// A configuration object that defines how a native alternative payment view controller content's.
/// Use `nil` to indicate that default value should be used.
public struct PONativeAlternativePaymentMethodConfiguration {

    /// Custom title.
    public let title: String?

    /// Custom success message to display user when payment completes.
    public let successMessage: String?

    /// Primary action text. Such as "Pay".
    public let primaryActionTitle: String?

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    public let skipSuccessScreen: Bool

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    public let waitsPaymentConfirmation: Bool

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Maximum value is 180 seconds.
    public let paymentConfirmationTimeout: TimeInterval

    public init(
        title: String? = nil,
        successMessage: String? = nil,
        primaryActionTitle: String? = nil,
        skipSuccessScreen: Bool = false,
        waitsPaymentConfirmation: Bool = true,
        paymentConfirmationTimeout: TimeInterval = 180
    ) {
        self.title = title
        self.successMessage = successMessage
        self.primaryActionTitle = primaryActionTitle
        self.skipSuccessScreen = skipSuccessScreen
        self.waitsPaymentConfirmation = waitsPaymentConfirmation
        self.paymentConfirmationTimeout = paymentConfirmationTimeout
    }
}
