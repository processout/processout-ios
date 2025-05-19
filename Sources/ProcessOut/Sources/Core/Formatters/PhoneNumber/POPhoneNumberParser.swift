//
//  POPhoneNumberUtil.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.05.2025.
//

import Foundation

@_spi(PO)
public struct POPhoneNumberParser {

    public static let shared = POPhoneNumberParser()

    init(metadataProvider: POPhoneNumberMetadataProvider = PODefaultPhoneNumberMetadataProvider.shared) {
        regexProvider = PORegexProvider.shared
        self.metadataProvider = metadataProvider
    }

    // MARK: -

    public func parse(number: String, defaultRegion: String? = nil) -> POPhoneNumber? {
        var normalizedNumber = normalize(number: number)
        let isInternational = removeInternationalPrefixIfPresent(number: &normalizedNumber)
        if isInternational {
            let metadata = metadata(forInternationalNumber: normalizedNumber)
            if !metadata.isEmpty {
                let countryCode = metadata[0].countryCode
                normalizedNumber.removeFirst(countryCode.count)
                return .init(
                    countryCode: countryCode, national: normalizedNumber, isInternational: true, metadata: metadata
                )
            }
        }
        if let defaultRegion, let countryCode = metadataProvider.countryCode(for: defaultRegion) {
            let metadata = metadataProvider.metadata(for: countryCode)
            if !metadata.isEmpty {
                return .init(
                    countryCode: countryCode, national: normalizedNumber, isInternational: false, metadata: metadata
                )
            }
        }
        return nil
    }

    public func regionCode(of phoneNumber: POPhoneNumber) -> String? {
        // Attempt to resolve region based on leading pattern
        for metadata in phoneNumber.metadata {
            for leading in metadata.formats.flatMap(\.leading) {
                guard let regex = regexProvider.regex(with: leading) else {
                    continue
                }
                let range = NSRange(
                    phoneNumber.national.startIndex ..< phoneNumber.national.endIndex, in: phoneNumber.national
                )
                if regex.firstMatch(in: phoneNumber.national, options: .anchored, range: range) != nil {
                    return metadata.id
                }
            }
        }
        return phoneNumber.metadata.first?.id
    }

    public func normalize(number: String) -> String {
        var normalizedNumber = number.applyingTransformDroppingInvalid(.toLatin, reverse: false)
        let validCharacters = CharacterSet(charactersIn: Constants.internationalCallPrefix).union(.decimalDigits)
        normalizedNumber = normalizedNumber.removingCharacters(in: validCharacters.inverted)
        let isInternational = normalizedNumber.starts(with: Constants.internationalCallPrefix)
        normalizedNumber = normalizedNumber.removingCharacters(
            in: CharacterSet(charactersIn: Constants.internationalCallPrefix)
        )
        if isInternational {
            normalizedNumber.insert(contentsOf: Constants.internationalCallPrefix, at: normalizedNumber.startIndex)
        }
        return normalizedNumber
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let internationalCallPrefix = "+"
    }

    // MARK: - Private Properties

    private let regexProvider: PORegexProvider
    private let metadataProvider: POPhoneNumberMetadataProvider

    // MARK: - Private Methods

    private func removeInternationalPrefixIfPresent(number: inout String) -> Bool {
        let isInternational = number.starts(with: Constants.internationalCallPrefix)
        if isInternational {
            number.removeFirst(1)
        }
        return isInternational
    }

    private func metadata(forInternationalNumber number: String) -> [POPhoneNumberMetadata] {
        var number = number
        let length = min(3, number.count)
        for i in stride(from: 1, through: length, by: 1) { // swiftlint:disable:this identifier_name
            let potentialCountryCode = String(number.prefix(i))
            let metadata = metadataProvider.metadata(for: potentialCountryCode)
            guard !metadata.isEmpty else {
                continue
            }
            number.removeFirst(i)
            return metadata
        }
        return []
    }
}

extension String {

    /// Applies a string transform to each character individually, preserving
    /// characters that fail to transform.
    func applyingTransformDroppingInvalid(_ transform: StringTransform, reverse: Bool) -> String {
        let characters = compactMap { character in
            String(character).applyingTransform(transform, reverse: reverse)
        }
        return characters.joined()
    }
}
