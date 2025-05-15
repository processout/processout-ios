//
//  POPhoneNumber.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.05.2025.
//

import Foundation

@_spi(PO)
public struct POPhoneNumber {

    /// E.164 Country Code.
    public let countryCode: String

    /// National number
    public let national: String

    /// Indicates whether initial number representation was international.
    public let isInternational: Bool

    /// All available metadata for phone numbers country code.
    let metadata: [POPhoneNumberMetadata]
}
