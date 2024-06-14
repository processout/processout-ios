//
//  POPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.03.2023.
//

@_spi(PO) public protocol POPhoneNumberMetadataProvider {

    /// Returns metadata for given country code if any.
    func metadata(for countryCode: String) -> POPhoneNumberMetadata?
}
