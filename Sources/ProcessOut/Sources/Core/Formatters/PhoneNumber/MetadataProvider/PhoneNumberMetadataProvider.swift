//
//  PhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.03.2023.
//

protocol PhoneNumberMetadataProvider {

    /// Returns metadata for given country code if any.
    func metadata(for countryCode: String) -> PhoneNumberMetadata?
}
