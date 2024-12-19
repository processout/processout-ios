//
//  CardSchemeProviderTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import Testing
@testable import ProcessOutUI

struct CardSchemeProviderTests {

    init() {
        let issuers: [CardSchemeProvider.Issuer] = [
            .init(scheme: "range", numbers: .range(10...11), length: 2),
            .init(scheme: "exact", numbers: .exact(1), length: 1),
            .init(scheme: "set", numbers: .set([2, 4]), length: 1)
        ]
        sut = CardSchemeProvider(issuers: issuers)
    }

    @Test
    func scheme_whenNumberStartsWithZero_returnsNil() {
        // When
        let scheme = sut.scheme(cardNumber: "0")

        // Then
        #expect(scheme == nil)
    }

    @Test
    func scheme_whenNumberDoesntContainDigits_returnsNil() {
        // When
        let scheme = sut.scheme(cardNumber: "a")

        // Then
        #expect(scheme == nil)
    }

    @Test
    func scheme_whenNumberLengthExceedsIinMinLength_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "1234 5678 9")

        // Then
        #expect(scheme != nil)
    }

    @Test
    func scheme_whenNumberMatchesExactPattern_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "1")

        // Then
        #expect(scheme?.rawValue == "exact")
    }

    @Test
    func scheme_whenNumberMatchesSetPattern_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "2")

        // Then
        #expect(scheme?.rawValue == "set")
    }

    @Test
    func scheme_whenNumberMatchesRangePattern_returnsScheme() {
        // When
        let scheme = sut.scheme(cardNumber: "10")

        // Then
        #expect(scheme?.rawValue == "range")
    }

    @Test
    func scheme_whenNumberIsUnknown_returnsNil() {
        // When
        let scheme = sut.scheme(cardNumber: "9")

        // Then
        #expect(scheme == nil)
    }

    // MARK: - Private Properties

    private let sut: CardSchemeProvider
}
