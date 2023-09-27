//
//  ImmutableExcludedCodableTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 29.03.2023.
//

import XCTest
@testable import ProcessOut

final class ImmutableExcludedCodableTests: XCTestCase {

    func test_excludedCodable_whenWrappedInContainer_isNotEncoded() throws {
        // Given
        let encoder = JSONEncoder()
        let value = Container(value: POImmutableExcludedCodable(value: 1))

        // When
        let encodeData = try encoder.encode(value)

        // Then
        XCTAssertEqual(Data("{}".utf8), encodeData)
    }
}

private struct Container: Encodable {

    @POImmutableExcludedCodable
    var value: Int
}
