//
//  CardSchemeProviderTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import XCTest
@testable import ProcessOutUI

final class CardSchemeProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let issuers: [CardSchemeProvider.Issuer] = [
            .init(scheme: .unknown("range"), numbers: .range(10...11), length: 2),
            .init(scheme: .unknown("exact"), numbers: .exact(1), length: 1),
            .init(scheme: .unknown("set"), numbers: .set([2, 4]), length: 1)
        ]
        sut = CardSchemeProvider(issuers: issuers)
    }

    func test_scheme_whenNumberStartsWithZero_returnsNil() {
        // When
        let scheme = sut.scheme(cardNumber: "0")

        // Then
        XCTAssertNil(scheme)
    }

    func test_scheme_whenNumberDoesntContainDigits_returnsNil() {
        // When
        let scheme = sut.scheme(cardNumber: "a")

        // Then
        XCTAssertNil(scheme)
    }

    func test_scheme_whenNumberLengthExceedsIinMinLength_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "1234 5678 9")

        // Then
        XCTAssertNotNil(scheme)
    }

    func test_scheme_whenNumberMatchesExactPattern_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "1")

        // Then
        XCTAssertEqual(scheme?.rawValue, "exact")
    }

    func test_scheme_whenNumberMatchesSetPattern_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "2")

        // Then
        XCTAssertEqual(scheme?.rawValue, "set")
    }

    func test_scheme_whenNumberMatchesRangePattern_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "10")

        // Then
        XCTAssertEqual(scheme?.rawValue, "range")
    }

    func test_scheme_whenNumberIsUnknown_returnsNil() {
        // When
        let scheme = sut.scheme(cardNumber: "9")

        // Then
        XCTAssertNil(scheme)
    }

    // MARK: - Private Properties

    private var sut: CardSchemeProvider!
}
