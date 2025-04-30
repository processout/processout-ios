//
//  JwkDecoder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

struct JwkDecoder: TopLevelJwkDecoder {

    init() {
        decoder = .init()
    }

    // MARK: - TopLevelJwkDecoder

    func decode(from base64UrlEncoded: String) throws(JwkDecodingError) -> Jwk {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            throw .dataCorruptedError(debugDescription: "Invalid Base64 URL encoded string.")
        }
        do {
            return try decoder.decode(Jwk.self, from: data)
        } catch {
            throw .dataCorruptedError(debugDescription: "Unable to decode JWK from JSON.", underlyingError: error)
        }
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
}
