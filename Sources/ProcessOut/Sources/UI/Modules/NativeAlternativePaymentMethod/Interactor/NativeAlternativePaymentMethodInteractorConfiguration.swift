//
//  Configuration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.03.2023.
//

import Foundation

struct NativeAlternativePaymentMethodInteractorConfiguration { // swiftlint:disable:this type_name

    /// Gateway configuration id.
    let gatewayConfigurationId: String

    /// Invoice identifier.
    let invoiceId: String

    /// Indicates whether interactor should wait for payment confirmation or not.
    let waitsPaymentConfirmation: Bool

    /// Maximum amount of time to wait for payment confirmation if it is enabled.
    let paymentConfirmationTimeout: TimeInterval
}
