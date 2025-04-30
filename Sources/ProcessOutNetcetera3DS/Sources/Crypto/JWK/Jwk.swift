//
//  Jwk.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

// swiftlint:disable identifier_name

struct Jwk: Decodable {

    /// Key type.
    let kty: String

    /// The "kid" (key ID).
    let kid: String?

    // MARK: - RSA

    /// RSA modulus (n), base64url-encoded
    let n: String?

    /// RSA public exponent (e), base64url-encoded
    let e: String?

    /// The named curve used.
    let crv: String?

    // MARK: - EC

    /// X coordinate of the EC point, base64url-encoded
    let x: String?

    ///  Y coordinate of the EC point, base64url-encoded
    let y: String?

    // MARK: - Certificates

    /// The X.509 certificate chain, with each entry as a base64-encoded DER certificate.
    let x5c: [String]?
}

// swiftlint:enable identifier_name
