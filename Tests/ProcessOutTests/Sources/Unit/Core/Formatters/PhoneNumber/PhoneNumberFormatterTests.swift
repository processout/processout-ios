//
//  PhoneNumberFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct PhoneNumberFormatterTests {

    init() {
        metadataProvider = MockPhoneNumberMetadataProvider()
        metadataProvider.metadata = []
        sut = POPhoneNumberFormatter(parser: .init(metadataProvider: metadataProvider))
    }

    @Test
    func normalized_retainsDigitsAndPlus() {
        // When
        let normalizedNumber = sut.normalized(number: "+1#")

        // Then
        #expect(normalizedNumber == "+1")
    }

    @Test
    func string_whenNumberIsEmpty_returnsEmptyString() {
        // When
        let formattedNumber = sut.string(from: "")

        // Then
        #expect(formattedNumber.isEmpty)
    }

    @Test
    func string_whenNumberDoesNotHaveDigitsNorPlus_returnsEmptyString() {
        // When
        let formattedNumber = sut.string(from: "#")

        // Then
        #expect(formattedNumber.isEmpty)
    }

    @Test
    func string_whenNumberHasOnlyPluses_returnsSinglePlus() {
        // When
        let formattedNumber = sut.string(from: "++")

        // Then
        #expect(formattedNumber == "+")
    }

    @Test
    func string_whenNumbersCountryCodeIsUnknown_returnsDigitsPrefixedWithPlus() {
        // When
        let formattedNumber = sut.string(from: "1")

        // Then
        #expect(formattedNumber == "+1")
    }

    @Test
    func string_whenNumberHasOnlyCountryCode_returnsCountryCodePrefixedWithPlus() {
        // Given
        metadataProvider.metadata = [.init(id: "T", countryCode: "0", formats: [])]

        // When
        let formattedNumber = sut.string(from: "0")

        // Then
        #expect(formattedNumber == "+0")
    }

    @Test
    func string_whenNumberIsComplete_returnsFormattedNumber() {
        // Given
        let format = POPhoneNumberMetadata.Format(pattern: "(\\d)(\\d)", leading: [".*"], format: "$1-$2")
        metadataProvider.metadata = [POPhoneNumberMetadata(id: "T", countryCode: "1", formats: [format])]

        // When
        let formattedNumber = sut.string(from: "123#")

        // Then
        #expect(formattedNumber == "+1 2-3")
    }

    @Test
    func string_whenNationalNumberLeadingDigitsAreUnknown_formatsCountryCode() {
        // Given
        let format = POPhoneNumberMetadata.Format(pattern: "", leading: [""], format: "")
        metadataProvider.metadata = [POPhoneNumberMetadata(id: "T", countryCode: "1", formats: [format])]

        // When
        let formattedNumber = sut.string(from: "123")

        // Then
        #expect(formattedNumber == "+1 23")
    }

    @Test
    func string_whenNationalNumberLengthExceedsMaximumLength_formatsCountryCode() {
        // Given
        let format = POPhoneNumberMetadata.Format(pattern: "", leading: [], format: "")
        metadataProvider.metadata = [POPhoneNumberMetadata(id: "T", countryCode: "1", formats: [format])]

        // When
        let formattedNumber = sut.string(from: "1123456789123456")

        // Then
        #expect(formattedNumber == "+1 123456789123456")
    }

    @Test
    func string_whenNumberContainsEasternArabicNumerals_returnsFormattedNumberWithLatinNumerals() {
        // Given
        let format = POPhoneNumberMetadata.Format(pattern: "(\\d)(\\d+)", leading: [".*"], format: "$1-$2")
        metadataProvider.metadata = [POPhoneNumberMetadata(id: "T", countryCode: "1", formats: [format])]

        // When
        let formattedNumber = sut.string(from: "١٢٣")

        // Then
        #expect(formattedNumber == "+1 2-3")
    }

    @Test
    func string_whenNumberIsPartial_returnsFormattedNumberWithoutTrailingSeparators() {
        // Given
        let format = POPhoneNumberMetadata.Format(pattern: "(\\d)(\\d)(\\d)", leading: [".*"], format: "$1-$2-$3")
        metadataProvider.metadata = [POPhoneNumberMetadata(id: "T", countryCode: "1", formats: [format])]

        // When
        let formattedNumber = sut.string(from: "123")

        // Then
        #expect(formattedNumber == "+1 2-3")
    }

    @Test
    func isPartialStringValid_formatsPartialString() {
        // Given
        var partialString = "1" as NSString // swiftlint:disable:this legacy_objc_type

        // When
        let isValid = sut.isPartialStringValid(
            &partialString,
            proposedSelectedRange: nil,
            originalString: "1",
            originalSelectedRange: NSRange(location: 0, length: 0),
            errorDescription: nil
        )

        // Then
        #expect(isValid && partialString == "+1")
    }

    @Test
    func isPartialStringValid_whenAddingText_updatesSelectedRange() {
        // Given
        var partialString = "001" as NSString // swiftlint:disable:this legacy_objc_type
        var proposedSelectedRange = NSRange(location: -1, length: -1)

        // When
        _ = sut.isPartialStringValid(
            &partialString,
            proposedSelectedRange: &proposedSelectedRange,
            originalString: "1",
            originalSelectedRange: NSRange(location: 0, length: 0),
            errorDescription: nil
        )

        // Then
        #expect(proposedSelectedRange == NSRange(location: 3, length: 0))
    }

    @Test
    func isPartialStringValid_whenRemovingText_updatesSelectedRange() {
        // Given
        var partialString = "14" as NSString // swiftlint:disable:this legacy_objc_type
        var proposedSelectedRange = NSRange(location: -1, length: -1)

        // When
        _ = sut.isPartialStringValid(
            &partialString,
            proposedSelectedRange: &proposedSelectedRange,
            originalString: "1234",
            originalSelectedRange: NSRange(location: 1, length: 2),
            errorDescription: nil
        )

        // Then
        #expect(proposedSelectedRange == NSRange(location: 2, length: 0))
    }

    // MARK: - Private Properties

    private let metadataProvider: MockPhoneNumberMetadataProvider
    private let sut: POPhoneNumberFormatter
}
