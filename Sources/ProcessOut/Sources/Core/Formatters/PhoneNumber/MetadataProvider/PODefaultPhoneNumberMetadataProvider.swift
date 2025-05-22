//
//  PODefaultPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

@_spi(PO)
public final class PODefaultPhoneNumberMetadataProvider: POPhoneNumberMetadataProvider, @unchecked Sendable {

    public static let shared = PODefaultPhoneNumberMetadataProvider()

    /// - NOTE: Method is asynchronous.
    public func prewarm() {
        Task(priority: .userInitiated) {
            unsafeInitialize()
        }
    }

    // MARK: - PhoneNumberMetadataProvider

    public func metadata(for countryCode: String) -> [POPhoneNumberMetadata] {
        let transformedCountryCode = countryCode
            .applyingTransformDroppingInvalid(.toLatin, reverse: false)
            .uppercased()
        let metadata = lock.withLock {
            unsafeInitialize()
            return self.metadata?[transformedCountryCode]
        }
        return metadata ?? []
    }

    public func countryCode(for regionCode: String) -> String? {
        let transformedCountryCode = regionCode
            .applyingTransformDroppingInvalid(.toLatin, reverse: false)
            .uppercased()
        let countryCode = lock.withLock {
            unsafeInitialize()
            return self.codes?[transformedCountryCode]
        }
        return countryCode
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked<Void>()

    /// Country code to metadata mappings.
    private var metadata: [String: [POPhoneNumberMetadata]]?

    /// Region code to country code mappings.
    private var codes: [String: String]?

    // MARK: - Private Methods

    private init() {
        // NOP
    }

    private func unsafeInitialize() {
        guard metadata == nil else {
            return
        }
        var metadata: [String: [POPhoneNumberMetadata]] = [:], codes: [String: String] = [:]
        do {
            let data = try Data(contentsOf: Files.phoneNumberMetadata.url)
            let decodedMetadata = try JSONDecoder().decode([POPhoneNumberMetadata].self, from: data)
            metadata.reserveCapacity(decodedMetadata.count)
            decodedMetadata.forEach { element in
                metadata[element.countryCode, default: []].append(element)
                codes[element.id] = element.countryCode
            }
        } catch {
            assertionFailure("Failed to load metadata: \(error)")
        }
        self.metadata = metadata
        self.codes = codes
    }
}
