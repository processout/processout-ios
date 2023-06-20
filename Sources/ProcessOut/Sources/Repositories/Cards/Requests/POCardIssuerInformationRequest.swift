//
//  POCardIssuerInformationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

/// Request to retrieve card issuer info.
public struct POCardIssuerInformationRequest {

    /// Card identification number. Corresponds to the first 6 or 8 digits of the main card number.
    public let iin: String

    /// Creates request instance.
    public init(iin: String) {
        self.iin = iin
    }
}
