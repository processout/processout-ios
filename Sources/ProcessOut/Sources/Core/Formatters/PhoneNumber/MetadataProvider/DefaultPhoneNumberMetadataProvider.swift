//
//  DefaultPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

final class DefaultPhoneNumberMetadataProvider: PhoneNumberMetadataProvider {

    static let shared = DefaultPhoneNumberMetadataProvider()

    /// - NOTE: Method is asynchronous.
    func prewarm() {
        loadMetadata(sync: false)
    }

    // MARK: - PhoneNumberMetadataProvider

    func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        let transformedCountryCode = countryCode.applyingTransform(.toLatin, reverse: false) ?? countryCode
        if let metadata = metadata {
            return metadata[transformedCountryCode]
        }
        loadMetadata(sync: true)
        return metadata?[transformedCountryCode]
    }

    // MARK: - Private Properties

    private let dispatchQueue: DispatchQueue

    @UnfairlyLocked
    private var metadata: [String: PhoneNumberMetadata]?

    // MARK: - Private Methods

    private init() {
        dispatchQueue = DispatchQueue(label: "process-out.phone-number-metadata-provider", qos: .userInitiated)
    }

    private func loadMetadata(sync: Bool) {
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self, self.metadata == nil else {
                return
            }
            let groupedMetadata: [String: PhoneNumberMetadata]
            do {
                let data = try Data(contentsOf: Files.phoneNumberMetadata.url)
                let metadata = try JSONDecoder().decode([PhoneNumberMetadata].self, from: data)
                groupedMetadata = Dictionary(grouping: metadata, by: \.countryCode).compactMapValues { values in
                    let countryCode = values.first!.countryCode // swiftlint:disable:this force_unwrapping
                    return PhoneNumberMetadata(countryCode: countryCode, formats: values.flatMap(\.formats))
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
