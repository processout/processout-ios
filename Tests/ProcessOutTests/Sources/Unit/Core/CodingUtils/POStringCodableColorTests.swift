//
//  POStringCodableColorTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 04.04.2024.
//

import Foundation
import UIKit
import Testing
@testable import ProcessOut

struct POStringCodableColorTests {

    @Test
    func init_whenBothStylesAreAvailable_decodesColor() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "dark": "FFDD007F", "light": "0x0057B7FF" }"#

        // When
        let colorWrapper = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))

        // Then
        expectEqual(color: colorWrapper.wrappedValue, to: 0xFFDD007F, style: .dark)
        expectEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .light)
    }

    @Test
    func init_whenOnlyLightStyleIsAvailable_decodesColor() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "light": "0x0057B7FF" }"#

        // When
        let colorWrapper = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))

        // Then
        expectEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .dark)
        expectEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .light)
    }

    @Test
    func init_whenLightStyleIsNotAvailable_fails() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "dark": "0x0057B7FF" }"#

        // Then
        withKnownIssue {
            _ = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))
        }
    }

    @Test
    func init_whenColorIsNotPrefixedWith0x_decodesColor() throws {
        // Given
        let decoder = JSONDecoder()
        let value = #"{ "light": "0057B7FF" }"#

        // When
        let colorWrapper = try decoder.decode(POStringCodableColor.self, from: Data(value.utf8))

        // Then
        expectEqual(color: colorWrapper.wrappedValue, to: 0x0057B7FF, style: .dark)
    }

    @Test
    func encode() throws {
        // Given
        let sut = UIColor(
            red: CGFloat(0x5B) / 255, green: CGFloat(0xFD) / 255, blue: CGFloat(0x8D) / 255, alpha: CGFloat(0x39) / 255
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        // Then
        let codableSut = POStringCodableColor(value: sut)
        let encodedColor = String(
            decoding: try encoder.encode(codableSut), as: UTF8.self
        )
        #expect(encodedColor == #"{"dark":"5BFD8D39","light":"5BFD8D39"}"#)
    }

    // MARK: - Private Methods

    private func expectEqual(color: UIColor, to hex: UInt64, style: UIUserInterfaceStyle) {
        let resolvedColor = color.resolvedColor(
            with: UITraitCollection(userInterfaceStyle: style)
        )
        expectEqual(color: resolvedColor, component: 0, to: hex >> 24)
        expectEqual(color: resolvedColor, component: 1, to: hex >> 16)
        expectEqual(color: resolvedColor, component: 2, to: hex >> 08)
        expectEqual(color: resolvedColor, component: 3, to: hex)
    }

    /// - Parameters:
    ///   - index: RGBA component index.
    ///   - value: Expected component value in range [0, 255]. Note that only 8 first bits are used.
    private func expectEqual(color: UIColor, component: Int, to value: UInt64) {
        guard let componentValue = color.cgColor.components?[component] else {
            Issue.record("Unable to get color component.")
            return
        }
        let expectedValue = CGFloat(value & 0xFF) / 255
        let tolerance: CGFloat = 0.01 // ~0.004% acceptable deviation
        #expect(abs(componentValue - expectedValue) < tolerance)
    }
}
