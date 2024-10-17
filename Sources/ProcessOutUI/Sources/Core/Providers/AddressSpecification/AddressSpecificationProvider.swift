//
//  AddressSpecificationProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.10.2023.
//

import Foundation
@_spi(PO) import ProcessOut

final class AddressSpecificationProvider: Sendable {

    static let shared = AddressSpecificationProvider()

    /// Preloads specifications.
    func prewarm() {
        DispatchQueue.global(qos: .userInitiated).async { _ = self.storage }
    }

    // MARK: - AddressSpecificationProvider

    /// Returns supported country codes.
    var countryCodes: [String] {
        storage.countryCodes
    }

    /// Returns address spec for given country code or default if country is unknown.
    func specification(for countryCode: String) -> AddressSpecification {
        storage.specifications[countryCode] ?? .default
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let resource = "AddressSpecifications.json"
    }

    // MARK: - Private Properties

    private let _storage = POUnfairlyLocked<Storage?>(wrappedValue: nil)

    // MARK: - Private Methods

    private init() {
        // NOP
    }

    private var storage: Storage {
        _storage.withLock { storage in
            if let storage {
                return storage
            }
            guard let url = BundleLocator.bundle.url(forResource: Constants.resource, withExtension: nil) else {
                preconditionFailure("Unable to find resource.")
            }
            let newStorage: Storage
            do {
                let data = try Data(contentsOf: url)
                let specifications = try JSONDecoder().decode([String: AddressSpecification].self, from: data)
                newStorage = Storage(
                    specifications: specifications, countryCodes: Array(specifications.keys)
                )
            } catch {
                assertionFailure("Failed to load metadata: \(error)")
                newStorage = Storage(specifications: [:], countryCodes: [])
            }
            storage = newStorage
            return newStorage
        }
    }
}

private final class Storage {

    init(specifications: [String: AddressSpecification], countryCodes: [String]) {
        self.specifications = specifications
        self.countryCodes = countryCodes
    }

    /// Country codes.
    var countryCodes: [String]

    /// Specifications.
    var specifications: [String: AddressSpecification]
}
