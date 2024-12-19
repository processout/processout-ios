//
//  CardSchemeImageProviderTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import Testing
@testable import ProcessOutUI

struct CardSchemeImageProviderTests {

    init() {
        sut = .shared
    }

    @Test
    func image_whenSchemeIsUnrecognized_returnsNil() {
        // When
        let image = sut.image(for: "unknown")

        // Then
        #expect(image == nil)
    }

    @Test
    func image_whenSchemeIsKnown_returnsImage() {
        // When
        let image = sut.image(for: .visa)

        // Then
        #expect(image != nil)
    }

    // MARK: - Private Properties

    private let sut: CardSchemeImageProvider
}
