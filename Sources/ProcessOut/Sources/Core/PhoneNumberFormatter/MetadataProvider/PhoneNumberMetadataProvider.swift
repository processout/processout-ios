//
//  PhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

final class PhoneNumberMetadataProvider: PhoneNumberMetadataProviderType {

    static let shared = PhoneNumberMetadataProvider()

    // MARK: - PhoneNumberMetadataProviderType

    func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        metadata[countryCode]
    }

    // MARK: - Private Methods

    private init() {
        // NOP
    }

    // MARK: - Private Properties

    private lazy var metadata: [String: PhoneNumberMetadata] = {
        guard let url = BundleLocator.bundle.url(forResource: "PhoneNumberMetadata", withExtension: "json") else {
            return [:]
        }
        do {
            let data = try Data(contentsOf: url)
            let metadata = try JSONDecoder().decode([PhoneNumberMetadata].self, from: data)
            return Dictionary(grouping: metadata, by: \.countryCode).compactMapValues { values in
                let countryCode = values.first!.countryCode // swiftlint:disable:this force_unwrapping
                return PhoneNumberMetadata(countryCode: countryCode, formats: values.flatMap(\.formats))
            }
        } catch {
            return [:]
        }
    }()
}
