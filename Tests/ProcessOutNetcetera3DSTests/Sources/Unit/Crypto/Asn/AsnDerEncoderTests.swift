//
//  AsnDerEncoderTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2025.
//

import Foundation
import Testing
@testable import ProcessOutNetcetera3DS

struct AsnDerEncoderTests {

    // MARK: - Integer

    @Test
    func encodeInteger() {
        // Given
        let integer = AsnInteger(rawValue: Data([0x3F]))

        // When
        let encoded = encoder.encode(integer)

        // Then
        #expect(encoded == Data([0x02, 0x01, 0x3F]))
    }

    @Test
    func encode_whenIntegerMsbIsSetToOne_addsPrefix() {
        // Given
        let integer = AsnInteger(rawValue: Data([0x80]))

        // When
        let encoded = encoder.encode(integer)

        // Then
        #expect(encoded == Data([0x02, 0x02, 0x00, 0x80]))
    }

    @Test
    func encode_whenIntegerHasRedundantLeadingPadding_stripsPadding() {
        // Given
        let integer = AsnInteger(rawValue: Data([0x00, 0x01]))

        // When
        let encoded = encoder.encode(integer)

        // Then
        #expect(encoded == Data([0x02, 0x01, 0x01]))
    }

    @Test
    func encode_whenIntegerHasValidLeadingPadding_keepsPadding() {
        // Given
        let integer = AsnInteger(rawValue: Data([0x00, 0x80]))

        // When
        let encoded = encoder.encode(integer)

        // Then
        #expect(encoded == Data([0x02, 0x02, 0x00, 0x80]))
    }

    @Test
    func encode_whenIntegerLengthExceeds127() {
        // Given
        let integer = AsnInteger(rawValue: Data(repeating: 0x01, count: 128))

        // When
        let encoded = encoder.encode(integer)

        // Then
        #expect(encoded == Data([0x02, 0x81, 0x80]) + integer.rawValue)
    }

    // MARK: - Bit String

    @Test
    func encode_whenBitStringWrapsPrimitive() {
        // Given
        let bitString = AsnBitString.primitive(Data([0x01]))

        // When
        let encoded = encoder.encode(bitString)

        // Then
        #expect(encoded == Data([0x03, 0x02, 0x00, 0x01]))
    }

    @Test
    func encode_whenBitStringEncapsulatesNull() {
        // Given
        let bitString = AsnBitString.encapsulated(.null)

        // When
        let encoded = encoder.encode(bitString)

        // Then
        #expect(encoded == Data([0x03, 0x03, 0x00, 0x05, 0x00]))
    }

    // MARK: - Null

    @Test
    func encodeNull() {
        // When
        let encoded = encoder.encode(.null)

        // Then
        #expect(encoded == Data([0x05, 0x00]))
    }

    // MARK: - Object Identifier

    @Test
    func encodeObjectIdentifier() {
        // Given
        let objectIdentifier = AsnObjectIdentifier.rsaEncryption

        // When
        let encoded = encoder.encode(objectIdentifier)

        // Then
        #expect(encoded == Data([0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01]))
    }

    // MARK: - Sequence

    @Test
    func encode_whenSequenceIsEmpty() {
        // Given
        let sequence = AsnSequence(elements: [])

        // When
        let encoded = encoder.encode(sequence)

        // Then
        #expect(encoded == Data([0x30, 0x00]))
    }

    @Test
    func encodeSequence() {
        // Given
        let sequence = AsnSequence(elements: [.null, .null])

        // When
        let encoded = encoder.encode(sequence)

        // Then
        #expect(encoded == Data([0x30, 0x04, 0x05, 0x00, 0x05, 0x00]))
    }

    // MARK: - Private Properties

    private let encoder = AsnDerEncoder()
}
