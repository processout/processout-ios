//
//  JwkAsnEncoder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

// swiftlint:disable identifier_name

final class JwkAsnEncoder: TopLevelJwkEncoder {

    func encode(_ jwk: Jwk) throws(JwkEncodingError) -> AsnNode {
        switch jwk.kty {
        case "RSA":
            return try encodeRsa(modulus: jwk.n, exponent: jwk.e)
        case "EC":
            return try encodeEc(crv: jwk.crv, x: jwk.x, y: jwk.y)
        default:
            throw .dataCorruptedError(debugDescription: "Unsupported key type: '\(jwk.kty)'.")
        }
    }

    // MARK: - RSA

    private func encodeRsa(modulus: String?, exponent: String?) throws(JwkEncodingError) -> AsnNode {
        guard let modulus = modulus.flatMap(Data.init(base64UrlEncoded:)),
              let exponent = exponent.flatMap(Data.init(base64UrlEncoded:)) else {
            throw .dataCorruptedError(debugDescription: "Invalid RSA public key.")
        }
        let encoded: AsnNode = .sequence(
            .sequence(AsnObjectIdentifier.rsaEncryption, .null),
            .bitString(
                encapsulating: .sequence(.integer(modulus), .integer(exponent))
            )
        )
        return encoded
    }

    // MARK: - EC

    private func encodeEc(crv: String?, x: String?, y: String?) throws(JwkEncodingError) -> AsnNode {
        guard let crv,
              let x = x.flatMap(Data.init(base64UrlEncoded:)),
              let y = y.flatMap(Data.init(base64UrlEncoded:)) else {
            throw .dataCorruptedError(debugDescription: "Invalid EC public key.")
        }
        let curveIdentifier: AsnObjectIdentifier = switch crv {
        case "P-192":
            .prime192v1
        case "P-256":
            .prime256v1
        case "P-384":
            .ansip384r1
        case "P-521":
            .ansip521r1
        default:
            throw .dataCorruptedError(debugDescription: "Unsupported elliptic curve: '\(crv)'.")
        }
        let encoded: AsnNode = .sequence(
            .sequence(AsnObjectIdentifier.ecPublicKey, curveIdentifier),
            .bitString(bits: [0x04] + x + y)
        )
        return encoded
    }
}

// swiftlint:enable identifier_name
