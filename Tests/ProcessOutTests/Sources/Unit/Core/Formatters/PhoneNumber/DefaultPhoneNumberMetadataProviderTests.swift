//
//  DefaultPhoneNumberMetadataProviderTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 16.05.2023.
//

import Testing
@testable @_spi(PO) import ProcessOut

struct DefaultPhoneNumberMetadataProviderTests {

    init() {
        sut = .shared
    }

    @Test
    func metadata_returnValidMetadata() {
        // When
        let metadata = sut.metadata(for: "1")

        // Then
        #expect(!metadata.isEmpty)
    }

    @Test
    func metadata_whenCountryCodeContainsEasternArabicNumerals_returnValidMetadata() {
        // When
        let metadata = sut.metadata(for: "١")

        // Then
        #expect(!metadata.isEmpty && metadata.first?.countryCode == "1")
    }

    // MARK: - Private Properties

    private let sut: PODefaultPhoneNumberMetadataProvider
}
