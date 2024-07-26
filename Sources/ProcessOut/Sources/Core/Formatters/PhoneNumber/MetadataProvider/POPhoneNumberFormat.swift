//
//  POPhoneNumberFormat.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

@_spi(PO)
public struct POPhoneNumberFormat: Decodable, Sendable {

    /// Formatting patern.
    public let pattern: String

    /// Leading digits pattern.
    public let leading: [String]

    /// Format to use for number.
    public let format: String
}
