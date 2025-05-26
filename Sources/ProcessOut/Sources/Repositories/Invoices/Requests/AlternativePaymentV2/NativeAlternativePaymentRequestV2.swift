//
//  NativeAlternativePaymentRequestV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.05.2025.
//

import Foundation

struct NativeAlternativePaymentRequestV2: Sendable {

    /// Invoice identifier.
    let invoiceId: String

    /// Gateway configuration identifier.
    let gatewayConfigurationId: String
}
