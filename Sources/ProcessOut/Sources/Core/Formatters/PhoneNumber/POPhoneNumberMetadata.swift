//
//  POPhoneNumberMetadata.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

@_spi(PO) public struct POPhoneNumberMetadata: Decodable {

    /// Country code.
    public let countryCode: String

    /// Available formats.
    public let formats: [POPhoneNumberFormat]
}
