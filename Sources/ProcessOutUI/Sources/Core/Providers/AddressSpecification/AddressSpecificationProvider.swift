//
//  AddressSpecificationProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.10.2023.
//

import Foundation
@_spi(PO) import ProcessOut

final class AddressSpecificationProvider {

    static let shared = AddressSpecificationProvider()

    /// Preloads specifications.
    func prewarm() {
        DispatchQueue.global(qos: .userInitiated).async { self.loadSpecifications() }
    }

    // MARK: - AddressSpecificationProvider

    /// Returns supported country codes.
    private(set) lazy var countryCodes: [String] = {
        Array(loadSpecifications().keys)
    }()

    /// Returns address spec for given country code or default if country is unknown.
    func specification(for countryCode: String) -> AddressSpecification {
        loadSpecifications()[countryCode] ?? .default
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let resource = "AddressSpecifications.json"
    }

    // MARK: - Private Properties

    @POUnfairlyLocked
    private var specifications: [String: AddressSpecification]?

    // MARK: - Private Methods

    private init() {
        // NOP
    }

    @discardableResult
    private func loadSpecifications() -> [String: AddressSpecification] {
        $specifications.withLock { specifications in
            if let specifications {
                return specifications
            }
            guard let url = BundleLocator.bundle.url(forResource: Constants.resource, withExtension: nil) else {
                preconditionFailure("Unable to find resource.")
            }
            do {
                let data = try Data(contentsOf: url)
                specifications = try JSONDecoder().decode([String: AddressSpecification].self, from: data)
            } catch {
                assertionFailure("Failed to load metadata: \(error)")
                specifications = [:]
            }
            return specifications ?? [:]
        }
    }
}
