//
//  POPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.03.2023.
//

@_spi(PO)
public protocol POPhoneNumberMetadataProvider: Sendable {

    /// Returns metadata for given country code if any.
    func metadata(for countryCode: String) -> [POPhoneNumberMetadata]

    /// Returns country code for given region code.
    func countryCode(for regionCode: String) -> String?
}
