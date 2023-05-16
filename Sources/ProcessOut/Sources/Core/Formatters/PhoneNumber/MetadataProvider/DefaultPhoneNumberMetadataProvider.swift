//
//  DefaultPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

final class DefaultPhoneNumberMetadataProvider: PhoneNumberMetadataProvider {

    static let shared = DefaultPhoneNumberMetadataProvider()

    // MARK: - PhoneNumberMetadataProvider

    func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        let transformedCountryCode = countryCode.applyingTransform(.toLatin, reverse: false) ?? countryCode
        return metadata[transformedCountryCode]
    }

    func prewarm() {
        _ = metadata
    }

    // MARK: - Private Methods

    private init() {
        // NOP
    }

    // MARK: - Private Properties

    private lazy var metadata: [String: PhoneNumberMetadata] = {
        let metadata: [PhoneNumberMetadata]
        do {
            let data = try Data(contentsOf: Files.phoneNumberMetadata.url)
            metadata = try JSONDecoder().decode([PhoneNumberMetadata].self, from: data)
        } catch {
            return [:]
        }
        return Dictionary(grouping: metadata, by: \.countryCode).compactMapValues { values in
            let countryCode = values.first!.countryCode // swiftlint:disable:this force_unwrapping
            return PhoneNumberMetadata(countryCode: countryCode, formats: values.flatMap(\.formats))
        }
    }()
}
