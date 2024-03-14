//
//  PODefaultPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

@_spi(PO) public final class PODefaultPhoneNumberMetadataProvider: POPhoneNumberMetadataProvider {

    public static let shared = PODefaultPhoneNumberMetadataProvider()

    /// - NOTE: Method is asynchronous.
    public func prewarm() {
        loadMetadata(sync: false)
    }

    // MARK: - PhoneNumberMetadataProvider

    public func metadata(for countryCode: String) -> POPhoneNumberMetadata? {
        let transformedCountryCode = countryCode.applyingTransform(.toLatin, reverse: false) ?? countryCode
        if let metadata = metadata {
            return metadata[transformedCountryCode]
        }
        loadMetadata(sync: true)
        return metadata?[transformedCountryCode]
    }

    // MARK: - Private Properties

    private let dispatchQueue: DispatchQueue

    @POUnfairlyLocked
    private var metadata: [String: POPhoneNumberMetadata]?

    // MARK: - Private Methods

    private init() {
        dispatchQueue = DispatchQueue(label: "process-out.phone-number-metadata-provider", qos: .userInitiated)
    }

    private func loadMetadata(sync: Bool) {
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self, self.metadata == nil else {
                return
            }
            let groupedMetadata: [String: POPhoneNumberMetadata]
            do {
                let data = try Data(contentsOf: Files.phoneNumberMetadata.url)
                let metadata = try JSONDecoder().decode([POPhoneNumberMetadata].self, from: data)
                groupedMetadata = Dictionary(grouping: metadata, by: \.countryCode).compactMapValues { values in
                    let countryCode = values.first!.countryCode // swiftlint:disable:this force_unwrapping
                    return POPhoneNumberMetadata(countryCode: countryCode, formats: values.flatMap(\.formats))
                }
            } catch {
                assertionFailure("Failed to load metadata: \(error)")
                groupedMetadata = [:]
            }
            self.$metadata.withLock { $0 = groupedMetadata }
        }
        let executor = sync ? dispatchQueue.sync : dispatchQueue.async
        executor(dispatchWorkItem)
    }
}
