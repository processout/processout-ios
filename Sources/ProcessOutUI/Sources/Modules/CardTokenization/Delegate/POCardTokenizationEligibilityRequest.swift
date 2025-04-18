//
//  POCardTokenizationEligibilityRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.04.2025.
//

import ProcessOut

public struct POCardTokenizationEligibilityRequest: Sendable {

    /// Card's issuer identification number.
    public let iin: String

    /// Resolved issuer information.
    public let issuerInformation: POCardIssuerInformation
}
