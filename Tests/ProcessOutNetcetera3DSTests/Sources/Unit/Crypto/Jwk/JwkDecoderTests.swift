//
//  JwkDecoderTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2025.
//

import Foundation
import Testing
@testable import ProcessOutNetcetera3DS

struct JwkDecoderTests {

    @Test
    func decode_whenEncodedValueEncodingIsInvalid_throws() throws {
        #expect(throws: JwkDecodingError.self) {
            _ = try sut.decode(from: " ")
        }
    }

    @Test
    func decode_whenEncodedValueIsValid_throws() throws {
        #expect(throws: JwkDecodingError.self) {
            _ = try sut.decode(from: "")
        }
    }

    @Test
    func decode_whenEncodedValueIsValid_succeeds() throws {
        // Given
        let encoded = #"eyAia3R5IjogIlJTQSIgfQ"#

        // When
        let decoded = try sut.decode(from: encoded)

        // Then
        #expect(decoded == Jwk(kty: "RSA", kid: nil, n: nil, e: nil, crv: nil, x: nil, y: nil, x5c: nil))
    }

    // MARK: - Private Properties

    private let sut = JwkDecoder()
}
