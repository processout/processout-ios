//
//  POStringCodableColor+Tests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 04.04.2024.
//

import XCTest
@testable import ProcessOut

final class POStringCodableColorTests: XCTestCase {

    func test_init_whenBothStylesAreAvailable_decodesColor() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "dark": "FFDD007F", "light": "0x0057B7FF" }"#

        // When
        let colorWrapper = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))

        // Then
        assertEqual(color: colorWrapper.wrappedValue, to: 0xFFDD007F, style: .dark)
        assertEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .light)
    }

    func test_init_whenOnlyLightStyleIsAvailable_decodesColor() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "light": "0x0057B7FF" }"#

        // When
        let colorWrapper = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))

        // Then
        assertEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .dark)
        assertEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .light)
    }

    func test_init_whenLightStyleIsNotAvailable_fails() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "dark": "0x0057B7FF" }"#

        // Then
        XCTAssertThrowsError(
            try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))
        )
    }

    func test_init_whenColorIsNotPrefixedWith0x_decodesColor() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "light": "0057B7FF" }"#

        // When
        let colorWrapper = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))

        // Then
        assertEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .dark)
    }

    // MARK: - Private Methods

    private func assertEqual(color: UIColor, to hex: UInt64, style: UIUserInterfaceStyle) {
        let resolvedColor = color.resolvedColor(
            with: UITraitCollection(userInterfaceStyle: style)
        )
        assertEqual(color: resolvedColor, component: 0, to: hex >> 24)
        assertEqual(color: resolvedColor, component: 1, to: hex >> 16)
        assertEqual(color: resolvedColor, component: 2, to: hex >> 08)
        assertEqual(color: resolvedColor, component: 3, to: hex)
    }

    /// - Parameters:
    ///   - index: RGBA component index.
    ///   - value: Expected component value in range [0, 255]. Note that only 8 first bits are used.
    private func assertEqual(color: UIColor, component: Int, to value: UInt64) {
        guard let componentValue = color.cgColor.components?[component] else {
            XCTFail("Unable to get color component.")
            return
        }
        let expectedValue = CGFloat(value & 0xFF) / 255
        let tolerance: CGFloat = 0.01 // ~0.004% acceptable deviation
        XCTAssert(abs(componentValue - expectedValue) < tolerance)
    }
}
