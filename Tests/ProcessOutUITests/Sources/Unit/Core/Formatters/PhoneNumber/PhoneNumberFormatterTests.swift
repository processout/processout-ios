//
//  PhoneNumberFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import XCTest
@testable @_spi(PO) import ProcessOut

final class PhoneNumberFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        metadataProvider = MockPhoneNumberMetadataProvider()
        metadataProvider.metadata = nil
        sut = POPhoneNumberFormatter(metadataProvider: metadataProvider)
    }

    func test_normalized_retainsDigitsAndPlus() {
        // When
        let normalizedNumber = sut.normalized(number: "+1#")

        // Then
        XCTAssertEqual(normalizedNumber, "+1")
    }

    func test_string_whenNumberIsEmpty_returnsEmptyString() {
        // When
        let formattedNumber = sut.string(from: "")

        // Then
        XCTAssertEqual(formattedNumber, "")
    }

    func test_string_whenNumberDoesNotHaveDigitsNorPlus_returnsEmptyString() {
        // When
        let formattedNumber = sut.string(from: "#")

        // Then
        XCTAssertEqual(formattedNumber, "")
    }

    func test_string_whenNumberHasOnlyPluses_returnsSinglePlus() {
        // When
        let formattedNumber = sut.string(from: "++")

        // Then
        XCTAssertEqual(formattedNumber, "+")
    }

    func test_string_whenNumbersCountryCodeIsUnknown_returnsDigitsPrefixedWithPlus() {
        // When
        let formattedNumber = sut.string(from: "1")

        // Then
        XCTAssertEqual(formattedNumber, "+1")
    }

    func test_string_whenNumberHasOnlyCountryCode_returnsCountryCodePrefixedWithPlus() {
        // Given
        metadataProvider.metadata = .init(countryCode: "0", formats: [])

        // When
        let formattedNumber = sut.string(from: "0")

        // Then
        XCTAssertEqual(formattedNumber, "+0")
    }

    func test_string_whenNumberIsComplete_returnsFormattedNumber() {
        // Given
        let format = POPhoneNumberFormat(pattern: "(\\d)(\\d)", leading: [".*"], format: "$1-$2")
        metadataProvider.metadata = POPhoneNumberMetadata(countryCode: "1", formats: [format])

        // When
        let formattedNumber = sut.string(from: "123#")

        // Then
        XCTAssertEqual(formattedNumber, "+1 2-3")
    }

    func test_string_whenNationalNumberLeadingDigitsAreUnknown_formatsCountryCode() {
        // Given
        let format = POPhoneNumberFormat(pattern: "", leading: [""], format: "")
        metadataProvider.metadata = POPhoneNumberMetadata(countryCode: "1", formats: [format])

        // When
        let formattedNumber = sut.string(from: "123")

        // Then
        XCTAssertEqual(formattedNumber, "+1 23")
    }

    func test_string_whenNationalNumberLengthExceedsMaximumLength_formatsCountryCode() {
        // Given
        let format = POPhoneNumberFormat(pattern: "", leading: [], format: "")
        metadataProvider.metadata = POPhoneNumberMetadata(countryCode: "1", formats: [format])

        // When
        let formattedNumber = sut.string(from: "1123456789123456")

        // Then
        XCTAssertEqual(formattedNumber, "+1 123456789123456")
    }

    func test_string_whenNumberContainsEasternArabicNumerals_returnsFormattedNumberWithLatinNumerals() {
        // Given
        let format = POPhoneNumberFormat(pattern: "(\\d)(\\d+)", leading: [".*"], format: "$1-$2")
        metadataProvider.metadata = POPhoneNumberMetadata(countryCode: "1", formats: [format])

        // When
        let formattedNumber = sut.string(from: "١٢٣")

        // Then
        XCTAssertEqual(formattedNumber, "+1 2-3")
    }

    func test_string_whenNumberIsPartial_returnsFormattedNumberWithoutTrailingSeparators() {
        // Given
        let format = POPhoneNumberFormat(pattern: "(\\d)(\\d)(\\d)", leading: [".*"], format: "$1-$2-$3")
        metadataProvider.metadata = POPhoneNumberMetadata(countryCode: "1", formats: [format])

        // When
        let formattedNumber = sut.string(from: "123")

        // Then
        XCTAssertEqual(formattedNumber, "+1 2-3")
    }

    func test_isPartialStringValid_formatsPartialString() {
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
        XCTAssert(isValid)
        XCTAssertEqual(partialString, "+1")
    }

    func test_isPartialStringValid_whenAddingText_updatesSelectedRange() {
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
        XCTAssertEqual(proposedSelectedRange, NSRange(location: 3, length: 0))
    }

    func test_isPartialStringValid_whenRemovingText_updatesSelectedRange() {
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
        XCTAssertEqual(proposedSelectedRange, NSRange(location: 2, length: 0))
    }

    // MARK: - Private Properties

    private var metadataProvider: MockPhoneNumberMetadataProvider!
    private var sut: POPhoneNumberFormatter!
}
