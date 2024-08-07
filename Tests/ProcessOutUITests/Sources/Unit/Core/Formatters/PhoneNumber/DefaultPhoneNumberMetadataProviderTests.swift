//
//  DefaultPhoneNumberMetadataProviderTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 16.05.2023.
//

import XCTest
@testable import ProcessOutUI

final class DefaultPhoneNumberMetadataProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = .shared
    }

    func test_metadata_returnValidMetadata() {
        // When
        let metadata = sut.metadata(for: "1")

        // Then
        XCTAssertNotNil(metadata)
    }

    func test_metadata_whenCountryCodeContainsEasternArabicNumerals_returnValidMetadata() {
        // When
        let metadata = sut.metadata(for: "١")

        // Then
        XCTAssertEqual(metadata?.countryCode, "1")
    }

    // MARK: - Private Properties

    private var sut: DefaultPhoneNumberMetadataProvider!
}
