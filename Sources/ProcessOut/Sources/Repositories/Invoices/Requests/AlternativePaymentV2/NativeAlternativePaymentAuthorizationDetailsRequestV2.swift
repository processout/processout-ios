//
//  NativeAlternativePaymentAuthorizationDetailsRequestV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.05.2025.
//

import Foundation

struct NativeAlternativePaymentAuthorizationDetailsRequestV2: Sendable { // swiftlint:disable:this type_name

    /// Invoice identifier.
    let invoiceId: String

    /// Gateway configuration identifier.
    let gatewayConfigurationId: String
}
