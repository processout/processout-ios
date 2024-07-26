//
//  DefaultPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation
@_spi(PO) import ProcessOut

final class DefaultPhoneNumberMetadataProvider: PhoneNumberMetadataProvider {

    public static let shared = DefaultPhoneNumberMetadataProvider()

    /// - NOTE: Method is asynchronous.
    public func prewarm() {
        loadMetadata(sync: false)
    }

    // MARK: - PhoneNumberMetadataProvider

    public func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        let transformedCountryCode = countryCode.applyingTransform(.toLatin, reverse: false) ?? countryCode
        if let metadata = metadata.wrappedValue {
            return metadata[transformedCountryCode]
        }
        loadMetadata(sync: true)
        return metadata.wrappedValue?[transformedCountryCode]
    }

    // MARK: - Private Properties

    private let dispatchQueue: DispatchQueue
    private let metadata = POUnfairlyLocked<[String: PhoneNumberMetadata]?>(wrappedValue: nil)

    // MARK: - Private Methods

    private init() {
        dispatchQueue = DispatchQueue(label: "process-out.phone-number-metadata-provider", qos: .userInitiated)
    }

    private func loadMetadata(sync: Bool) {
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self, self.metadata.wrappedValue == nil else {
                return
            }
            let groupedMetadata: [String: PhoneNumberMetadata]
            do {
                let data = try Data(
                    contentsOf: BundleLocator.bundle.url(forResource: "PhoneNumberMetadata", withExtension: "json")!
                )
                let metadata = try JSONDecoder().decode([PhoneNumberMetadata].self, from: data)
                groupedMetadata = Dictionary(grouping: metadata, by: \.countryCode).compactMapValues { values in
                    let countryCode = values.first!.countryCode // swiftlint:disable:this force_unwrapping
                    return PhoneNumberMetadata(countryCode: countryCode, formats: values.flatMap(\.formats))
                }
            } catch {
                assertionFailure("Failed to load metadata: \(error)")
                groupedMetadata = [:]
            }
            self.metadata.withLock { $0 = groupedMetadata }
        }
        let executor = sync ? dispatchQueue.sync : dispatchQueue.async
        executor(dispatchWorkItem)
    }
}
