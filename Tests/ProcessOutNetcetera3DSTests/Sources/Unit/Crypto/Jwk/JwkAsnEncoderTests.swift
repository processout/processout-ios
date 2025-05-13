//
//  JwkAsnEncoderTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2025.
//

import Foundation
import Testing
@testable import ProcessOutNetcetera3DS

struct JwkAsnEncoderTests {

    // MARK: - Unknown Key Type

    @Test
    func encode_whenKeyTypeIsNotSupported_throws() throws {
        // Given
        let jwk = Jwk(kty: "oct", kid: nil, n: nil, e: nil, crv: nil, x: nil, y: nil, x5c: nil)

        // When
        #expect(throws: JwkEncodingError.self) {
            _ = try sut.encode(jwk)
        }
    }

    // MARK: - RSA

    @Test
    func encodeRsaKey() throws {
        // Given
        let jwk = Jwk(kty: "RSA", kid: nil, n: "MODULUS", e: "EXPONENT", crv: nil, x: nil, y: nil, x5c: nil)

        // When
        let encoded = try sut.encode(jwk)

        // Then
        let expectedDerEncodedKey = Data("MCMwDQYJKoZIhvcNAQEBBQADEgAwDwIFMODULUQCBhFzzjRDUw==".utf8)
        #expect(AsnDerEncoder().encode(encoded).base64EncodedData() == expectedDerEncodedKey)
    }

    // MARK: - EC

    @Test
    func encode_whenEcCurveIsNotSupported_fails() throws {
        // Given
        let jwk = Jwk(kty: "EC", kid: nil, n: nil, e: nil, crv: "secp256k1", x: "AQAB", y: "AQAB", x5c: nil)

        // When
        #expect(throws: JwkEncodingError.self) {
            _ = try sut.encode(jwk)
        }
    }

    @Test
    func encode_whenEcCurveIsSupported_succeeds() throws {
        // Given
        let jwk = Jwk(
            kty: "EC",
            kid: nil,
            n: nil,
            e: nil,
            crv: "P-256",
            x: "f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
            y: "x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0",
            x5c: nil
        )

        // When
        let encoded = try sut.encode(jwk)

        // Then
        let expectedDerEncodedKey = Data(
            """
            MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEf83OJ3D2xF1Bg8vub9tLe1gHMz\
            V76e8Tus9uPHvRVEXH8UTNG72bfocs3+257rn0s2ldbqkLJK2KRiMohYjlrQ==
            """.utf8
        )
        #expect(AsnDerEncoder().encode(encoded).base64EncodedData() == expectedDerEncodedKey)
    }

    // MARK: - Private Properties

    private let sut = JwkAsnEncoder()
}
