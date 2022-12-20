//
//  PONativeAlternativePaymentMethodState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.11.2022.
//

import Foundation

public enum NativeAlternativePaymentMethodState: String, Decodable {

    /// Additional input is required.
    case customerInput = "CUSTOMER_INPUT"

    /// Invoice is pending capture.
    case pendingCapture = "PENDING_CAPTURE"

    /// Invoice is captured.
    case captured = "CAPTURED"
}
