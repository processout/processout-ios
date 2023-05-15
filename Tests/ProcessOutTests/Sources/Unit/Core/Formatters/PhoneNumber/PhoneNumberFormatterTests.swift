//
//  PhoneNumberFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import XCTest
@testable import ProcessOut

final class PhoneNumberFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        metadataProvider = MockPhoneNumberMetadataProvider()
        sut = PhoneNumberFormatter(metadataProvider: metadataProvider)
    }

    func test_string_whenInputIsEmpty_returnsEmptyString() {
        // When
        let formattedNumber = sut.string(from: "")

        // Then
        XCTAssertEqual(formattedNumber, "")
    }

    func test_string_whenInputDoesNotContainDigitsNorPlus_returnsEmptyString() {
        // When
        let formattedNumber = sut.string(from: "#")

        // Then
        XCTAssertEqual(formattedNumber, "")
    }

    func test_string_whenInputContainsOnlyPlus_preservesIt() {
        // When
        let formattedNumber = sut.string(from: "+")

        // Then
        XCTAssertEqual(formattedNumber, "+")
    }

    func test_string_whenInputStartsWithUnknownCountryCode_returnsDigitsPrefixedWithPlus() {
        // Given
        metadataProvider.metadata = nil

        // When
        let formattedNumber = sut.string(from: "1")

        // Then
        XCTAssertEqual(formattedNumber, "+1")
    }

    func test_string_whenInputHasOnlyCountryCode_returnsCountryCodePrefixedWithPlus() {
        // Given
        metadataProvider.metadata = .init(countryCode: "0", formats: [])

        // When
        let formattedNumber = sut.string(from: "0")

        // Then
        XCTAssertEqual(formattedNumber, "+0")
    }

    func test_string_whenInputIsFull_returnsFormattedNumber() {
        // Given
        let format = PhoneNumberFormat(pattern: "(\\d)(\\d)", leading: [".*"], format: "$1-$2")
        metadataProvider.metadata = PhoneNumberMetadata(countryCode: "1", formats: [format])

        // When
        let formattedNumber = sut.string(from: "123#")

        // Then
        XCTAssertEqual(formattedNumber, "+1 2-3")
    }

    func test_string_whenNationalNumberLeadingDigitsAreUnknown_returnsNationalNumberPrefixWithPlusAndCountryCode() {
        // Given
        let formats: [PhoneNumberFormat] = [
            PhoneNumberFormat(pattern: "", leading: [""], format: "")
        ]
        metadataProvider.metadata = PhoneNumberMetadata(countryCode: "1", formats: formats)

        // When
        let formattedNumber = sut.string(from: "12")

        // Then
        XCTAssertEqual(formattedNumber, "+1 2")
    }

    // MARK: - Private Properties

    private var metadataProvider: MockPhoneNumberMetadataProvider!
    private var sut: PhoneNumberFormatter!
}
