//
//  CardSchemeImageProviderTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import XCTest
@testable import ProcessOutUI

final class CardSchemeImageProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = .shared
    }

    func test_image_whenSchemeIsUnrecognized_returnsNil() {
        // When
        let image = sut.image(for: "<?>")

        // Then
        XCTAssertNil(image)
    }

    func test_image_whenSchemeIsKnown_returnsImage() {
        // When
        let image = sut.image(for: "visa")

        // Then
        XCTAssertNotNil(image)
    }

    func test_image_whenSchemeIsKnownButCaseIsDifferent_returnsImage() {
        // When
        let image = sut.image(for: "ViSa")

        // Then
        XCTAssertNotNil(image)
    }

    // MARK: - Private Properties

    private var sut: CardSchemeImageProvider!
}
